// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Management.Automation;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Pipeline.Export;

/// <summary>
/// A base context to export data from Azure.
/// </summary>
internal abstract class ExportDataContext : IDisposable, ILogger
{
    protected const string RESOURCE_MANAGER_URL = "https://management.azure.com";

    private const string HEADERS_MEDIA_TYPE_JSON = "application/json";
    private const string HEADERS_AUTHORIZATION_BEARER = "Bearer";
    private const string HEADERS_CORRELATION_ID = "x-ms-correlation-request-id";

    private const string PROPERTY_VALUE = "value";

    private readonly AccessTokenCache _TokenCache;
    private readonly CancellationTokenSource _Cancel;
    private readonly int _RetryCount;
    private readonly TimeSpan _RetryInterval;
    private readonly PipelineContext _Context;
    private readonly ConcurrentQueue<Message> _Logger;
    private readonly string[] _CorrelationId;

    private bool _Disposed;

    public ExportDataContext(PipelineContext context, AccessTokenCache tokenCache, int retryCount = 3, int retryInterval = 10)
    {
        _TokenCache = tokenCache;
        _Cancel = new CancellationTokenSource();
        _RetryCount = retryCount;
        _RetryInterval = TimeSpan.FromSeconds(retryInterval);
        _Context = context;
        _Logger = new ConcurrentQueue<Message>();
        _CorrelationId = [Guid.NewGuid().ToString()];
    }

    private readonly struct Message
    {
        public Message(TraceLevel level, string text)
        {
            Level = level;
            Text = text;
        }

        public TraceLevel Level { get; }

        public string Text { get; }
    }

    protected void RefreshToken(string tenantId)
    {
        _TokenCache.RefreshToken(tenantId);
    }

    protected void RefreshAll()
    {
        _TokenCache.RefreshAll();
    }

    protected SecureString GetToken(string tenantId)
    {
        return _TokenCache.GetToken(tenantId);
    }

    private HttpClient GetClient(string tenantId)
    {
        var client = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(90)
        };
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(HEADERS_AUTHORIZATION_BEARER, new NetworkCredential(string.Empty, GetToken(tenantId)).Password);
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue(HEADERS_MEDIA_TYPE_JSON));
        client.DefaultRequestHeaders.Add(HEADERS_CORRELATION_ID, _CorrelationId);
        return client;
    }

    protected static string GetEndpointUri(string baseEndpoint, string requestUri, string apiVersion, string? queryString)
    {
        var query = string.IsNullOrWhiteSpace(queryString) ? "?" : $"?{queryString}&";
        return string.Concat(baseEndpoint, "/", requestUri, query, "api-version=", apiVersion);
    }

    protected async Task<JObject[]> ListAsync(string tenantId, string uri, bool ignoreNotFound)
    {
        var results = new List<JObject>();
        var json = await GetRequestAsync(tenantId, uri, ignoreNotFound);
        while (!string.IsNullOrEmpty(json))
        {
            var payload = JsonConvert.DeserializeObject<JObject>(json);
            if (payload.TryGetProperty(PROPERTY_VALUE, out JArray data))
                results.AddRange(data.Values<JObject>());

            json = payload.TryGetProperty("nextLink", out var nextLink) &&
                !string.IsNullOrEmpty(nextLink) ? await GetRequestAsync(tenantId, nextLink, ignoreNotFound) : null;
        }
        return [.. results];
    }

    protected async Task<JObject> GetAsync(string tenantId, string uri)
    {
        var json = await GetRequestAsync(tenantId, uri, ignoreNotFound: false);
        if (string.IsNullOrEmpty(json))
            return null;

        var result = JsonConvert.DeserializeObject<JObject>(json);
        return result;
    }

    private async Task<string> GetRequestAsync(string tenantId, string uri, bool ignoreNotFound)
    {
        var attempt = 0;
        using var client = GetClient(tenantId);
        try
        {
            do
            {
                attempt++;

                var response = await client.GetAsync(uri, _Cancel.Token);
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    return json;
                }
                else if (response.StatusCode == HttpStatusCode.NotFound)
                {
                    if (!ignoreNotFound)
                        this.WarnFailedToGet(uri, response.StatusCode, _CorrelationId[0], await response.Content.ReadAsStringAsync());

                    return null;
                }
                else if (!ShouldRetry(response.StatusCode))
                {
                    this.WarnFailedToGet(uri, response.StatusCode, _CorrelationId[0], await response.Content.ReadAsStringAsync());
                    return null;
                }
                else
                {
                    this.WarnFailedToGet(uri, response.StatusCode, _CorrelationId[0], await response.Content.ReadAsStringAsync());
                    var retry = response.Headers.RetryAfter.Delta.GetValueOrDefault(_RetryInterval);
                    this.VerboseRetryIn(uri, retry, attempt);
                    Thread.Sleep(retry);
                }

            } while (attempt <= _RetryCount);
        }
        finally
        {
            // Do nothing
        }
        return null;
    }

    private static bool ShouldRetry(HttpStatusCode statusCode)
    {
        return statusCode == HttpStatusCode.RequestTimeout ||
            statusCode == HttpStatusCode.BadGateway ||
            statusCode == HttpStatusCode.ServiceUnavailable ||
            statusCode == HttpStatusCode.GatewayTimeout ||
            (int)statusCode == 429 /* Too many Requests */;
    }

    protected virtual void Dispose(bool disposing)
    {
        if (!_Disposed)
        {
            if (disposing)
            {
                _Cancel.Cancel();
                _Cancel.Dispose();
            }
            _Disposed = true;
        }
    }

    public void Dispose()
    {
        Dispose(disposing: true);
        GC.SuppressFinalize(this);
    }

    #region ILogger

    void ILogger.WriteVerbose(string message)
    {
        if (_Context == null)
            return;

        _Logger.Enqueue(new Message(TraceLevel.Verbose, message));
    }

    void ILogger.WriteVerbose(string format, params object[] args)
    {
        if (_Context == null)
            return;

        _Logger.Enqueue(new Message(TraceLevel.Verbose, string.Format(Thread.CurrentThread.CurrentCulture, format, args)));
    }

    internal void WriteDiagnostics()
    {
        if (_Context == null || _Logger.IsEmpty)
            return;

        while (!_Logger.IsEmpty && _Logger.TryDequeue(out var message))
        {
            if (message.Level == TraceLevel.Verbose)
                _Context.Writer.WriteVerbose(message.Text);
            else if (message.Level == TraceLevel.Warning)
                _Context.Writer.WriteWarning(message.Text);
        }
    }

    void ILogger.WriteWarning(string message)
    {
        if (_Context == null)
            return;

        _Logger.Enqueue(new Message(TraceLevel.Warning, message));
    }

    void ILogger.WriteWarning(string format, params object[] args)
    {
        if (_Context == null)
            return;

        _Logger.Enqueue(new Message(TraceLevel.Warning, string.Format(Thread.CurrentThread.CurrentCulture, format, args)));
    }

    public void WriteError(Exception exception, string errorId, ErrorCategory errorCategory, object targetObject)
    {
        if (_Context == null)
            return;

        _Logger.Enqueue(new Message(TraceLevel.Warning, exception.Message));
    }

    #endregion ILogger
}

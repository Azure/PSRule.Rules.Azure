// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Concurrent;
using System.Threading;

namespace PSRule.Rules.Azure.Pipeline.Export;

/// <summary>
/// Define a cache for storing and refreshing tokens.
/// </summary>
internal sealed class AccessTokenCache : IDisposable
{
    private readonly GetAccessTokenFn _GetToken;
    private readonly CancellationTokenSource _Cancel;
    private readonly ConcurrentDictionary<string, AccessToken> _Cache;

    private bool _Disposed;

    /// <summary>
    /// Create an instance of a token cache.
    /// </summary>
    /// <param name="getToken">A delegate method to get a token for a tenant.</param>
    public AccessTokenCache(GetAccessTokenFn getToken)
    {
        _GetToken = getToken;
        _Cache = new ConcurrentDictionary<string, AccessToken>();
        _Cancel = new CancellationTokenSource();
    }

    /// <summary>
    /// Check and refresh all tokens as required.
    /// </summary>
    internal void RefreshAll()
    {
        var tokens = _Cache.ToArray();
        for (var i = 0; i < tokens.Length; i++)
        {
            if (tokens[i].Value.ShouldRefresh())
            {
                var token = _GetToken.Invoke(tokens[i].Value.TenantId);
                if (token != null)
                    _Cache.TryUpdate(tokens[i].Key, token, tokens[i].Value);
            }
        }
    }

    /// <summary>
    /// Refresh a token for the specified tenant.
    /// </summary>
    /// <param name="tenantId">The tenant Id of the specific tenant to refresh the token for.</param>
    internal void RefreshToken(string tenantId)
    {
        if (!_Cache.TryGetValue(tenantId, out var oldToken))
        {
            var newToken = _GetToken.Invoke(tenantId);
            if (newToken != null)
                _Cache.TryAdd(tenantId, newToken);
        }
        else if (oldToken.ShouldRefresh())
        {
            var newToken = _GetToken.Invoke(tenantId);
            if (newToken != null)
                _Cache.TryUpdate(tenantId, newToken, oldToken);
        }
    }

    /// <summary>
    /// Get an access token for the specified tenant.
    /// The token will be synchronized to the main thread.
    /// </summary>
    /// <param name="tenantId">The tenant Id of the specific tenant to get a token for.</param>
    /// <returns>An access token or <c>null</c>.</returns>
    internal string GetToken(string tenantId)
    {
        while (!_Cancel.IsCancellationRequested)
        {
            if (!_Cache.TryGetValue(tenantId, out var token))
            {
                _Cache.TryAdd(tenantId, new AccessToken(tenantId));
            }
            else if (!token.ShouldRefresh())
            {
                return token.Token;
            }
            Thread.Sleep(100);
        }
        return null;
    }

    internal void Cancel()
    {
        _Cancel.Cancel();
    }

    #region IDisposable

    private void Dispose(bool disposing)
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

    #endregion IDisposable
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Concurrent;
using System.Security;
using System.Threading;

namespace PSRule.Rules.Azure.Pipeline.Export;

/// <summary>
/// Define a cache for storing and refreshing tokens.
/// </summary>
/// <param name="getToken">A delegate method to get a token for a tenant.</param>
internal sealed class AccessTokenCache(GetAccessTokenFn getToken) : IDisposable
{
    private readonly GetAccessTokenFn _GetToken = getToken;
    private readonly CancellationTokenSource _Cancel = new();
    private readonly ConcurrentDictionary<string, AccessToken> _Cache = new();

    private bool _Disposed;

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
                {
                    _Cache.TryUpdate(tokens[i].Key, token, tokens[i].Value);
                }
            }
        }
    }

    /// <summary>
    /// Refresh a token for the specified tenant.
    /// </summary>
    /// <param name="tenantId">The tenant Id of the specific tenant to refresh the token for.</param>
    internal void RefreshToken(string tenantId)
    {
        _ = GetToken(tenantId);
    }

    /// <summary>
    /// Get an access token for the specified tenant.
    /// The token will be synchronized to the main thread.
    /// </summary>
    /// <param name="tenantId">The tenant Id of the specific tenant to get a token for.</param>
    /// <returns>An access token or <c>null</c>.</returns>
    internal SecureString GetToken(string tenantId)
    {
        while (!_Cancel.IsCancellationRequested)
        {
            if (_Cache.TryGetValue(tenantId, out var token) && token != null && !token.ShouldRefresh())
                return token.Token;

            var newToken = _GetToken.Invoke(tenantId);
            if (newToken != null && token != null && _Cache.TryUpdate(tenantId, newToken, token))
                return newToken.Token;

            if (newToken != null && token == null && _Cache.TryAdd(tenantId, newToken))
                return newToken.Token;

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

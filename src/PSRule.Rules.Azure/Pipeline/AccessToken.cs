// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// An OAuth2 access token.
/// </summary>
public sealed class AccessToken
{
    /// <summary>
    /// Create an instance of an access token.
    /// </summary>
    /// <param name="token">The base64 encoded token.</param>
    /// <param name="expiry">An offset for when the token expires.</param>
    /// <param name="tenantId">A unique identifier for the Azure AD tenent associated to the token.</param>
    public AccessToken(string token, DateTimeOffset expiry, string tenantId)
    {
        Token = token;
        Expiry = expiry.DateTime;
        TenantId = tenantId;
    }

    internal AccessToken(string tenantId)
    {
        Token = null;
        Expiry = DateTime.MinValue;
        TenantId = tenantId;
    }

    /// <summary>
    /// The base64 encoded token.
    /// </summary>
    public string Token { get; }

    /// <summary>
    /// An offset for when the token expires.
    /// </summary>
    public DateTime Expiry { get; }

    /// <summary>
    /// A unique identifier for the Azure AD tenent associated to the token.
    /// </summary>
    public string TenantId { get; }

    /// <summary>
    /// Determine if the access token should be refreshed.
    /// </summary>
    internal bool ShouldRefresh()
    {
        return DateTime.UtcNow.AddSeconds(180) > Expiry;
    }
}

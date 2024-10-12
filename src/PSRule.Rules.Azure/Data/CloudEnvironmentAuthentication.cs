// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// Authentication properties for the cloud environment.
/// </summary>
public sealed class CloudEnvironmentAuthentication
{
    /// <summary>
    /// Azure AD login endpoint.
    /// Defaults to <c>https://login.microsoftonline.com/</c>.
    /// </summary>
    [JsonProperty(PropertyName = "loginEndpoint")]
    public string loginEndpoint { get; set; }

    /// <summary>
    /// Azure Resource Manager audiences.
    /// </summary>
    [JsonProperty(PropertyName = "audiences")]
    public string[] audiences { get; set; }

    /// <summary>
    /// Azure AD tenant to use.
    /// Default to <c>common</c>.
    /// </summary>
    [JsonProperty(PropertyName = "tenant")]
    public string tenant { get; set; }

    /// <summary>
    /// The identity provider to use.
    /// Defaults to <c>AAD</c>.
    /// </summary>
    [JsonProperty(PropertyName = "identityProvider")]
    public string identityProvider { get; set; }
}

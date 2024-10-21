// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// Defines a datastore of secret properties for Azure resources.
/// </summary>
internal sealed class SecretPropertyData : ResourceLoader
{
    private const string RESOURCE_PATH = "secret-property.min.json.deflated";

    /// <summary>
    /// Settings for JSON deserialization.
    /// </summary>
    private static readonly JsonSerializerSettings _Settings = new()
    {
        Converters =
        [
            new ReadOnlyDictionaryConverter<string[]>(StringComparer.OrdinalIgnoreCase),
        ]
    };

    private IReadOnlyDictionary<string, string[]> _SecretProperty;

#nullable enable

    /// <summary>
    /// Get a template for a secret.
    /// </summary>
    /// <param name="resourceType">The resource type.</param>
    /// <param name="properties">A list of secret properties for the resource type..</param>
    /// <returns>Return <c>true</c> when the resource type was found. Otherwise, <c>false</c> is returned.</returns>
    public bool TryGetValue(string resourceType, out string[]? properties)
    {
        _SecretProperty ??= ReadSecretProperty(GetContent(RESOURCE_PATH));
        return _SecretProperty.TryGetValue(resourceType, out properties);
    }

#nullable restore

    /// <summary>
    /// Deserialize a secret property structure from JSON.
    /// </summary>
    private static IReadOnlyDictionary<string, string[]> ReadSecretProperty(string content)
    {
        return JsonConvert.DeserializeObject<IReadOnlyDictionary<string, string[]>>(content, _Settings) ?? throw new JsonException(PSRuleResources.CloudEnvironmentInvalid);
    }
}

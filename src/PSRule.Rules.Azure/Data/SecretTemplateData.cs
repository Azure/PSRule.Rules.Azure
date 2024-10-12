// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// Defines a datastore of possible secret templates that can be used with the list*() functions.
/// </summary>
internal sealed class SecretTemplateData : ResourceLoader
{
    private const string RESOURCE_PATH = "secret-template.min.json.deflated";

    /// <summary>
    /// Settings for JSON deserialization.
    /// </summary>
    private static readonly JsonSerializerSettings _Settings = new()
    {
        Converters =
        [
            new ReadOnlyDictionaryConverter<JObject>(StringComparer.OrdinalIgnoreCase),
        ]
    };

    private IReadOnlyDictionary<string, JObject> _SecretTemplate;

#nullable enable

    /// <summary>
    /// Get a template for a secret.
    /// </summary>
    /// <param name="resourceType">The resource type.</param>
    /// <param name="method">The secret method to call. e.g. <c>listKeys</c>.</param>
    /// <param name="value">The <seealso cref="JObject"/> for the template.</param>
    /// <returns>Return <c>true</c> when the resource type and method were found. Otherwise, <c>false</c> is returned.</returns>
    public bool TryGetValue(string resourceType, string method, out JObject? value)
    {
        value = null;
        _SecretTemplate ??= ReadSecretTemplate(GetContent(RESOURCE_PATH));
        return _SecretTemplate.TryGetValue(resourceType, out var type) &&
            type.TryObjectProperty(method, out value);
    }

#nullable restore

    /// <summary>
    /// Deserialize a secret template from JSON.
    /// </summary>
    private static IReadOnlyDictionary<string, JObject> ReadSecretTemplate(string content)
    {
        return JsonConvert.DeserializeObject<IReadOnlyDictionary<string, JObject>>(content, _Settings) ?? throw new JsonException(PSRuleResources.CloudEnvironmentInvalid);
    }
}

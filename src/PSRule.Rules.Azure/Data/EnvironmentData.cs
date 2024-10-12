// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// Defines a datastore of Azure environment data.
/// </summary>
internal sealed class EnvironmentData : ResourceLoader
{
    private const string RESOURCE_PATH = "environments.min.json.deflated";

    /// <summary>
    /// Settings for JSON deserialization.
    /// </summary>
    private static readonly JsonSerializerSettings _Settings = new()
    {
        Converters =
        [
            new ReadOnlyDictionaryConverter<CloudEnvironment>(StringComparer.OrdinalIgnoreCase),
        ]
    };

    private IReadOnlyDictionary<string, CloudEnvironment> _Environments;

    public CloudEnvironment Get(string name)
    {
        _Environments ??= ReadEnvironments(GetContent(RESOURCE_PATH));
        return _Environments[name];
    }

    /// <summary>
    /// Deserialize an environments from JSON.
    /// </summary>
    private static IReadOnlyDictionary<string, CloudEnvironment> ReadEnvironments(string content)
    {
        return JsonConvert.DeserializeObject<IReadOnlyDictionary<string, CloudEnvironment>>(content, _Settings) ?? throw new JsonException(PSRuleResources.CloudEnvironmentInvalid);
    }
}

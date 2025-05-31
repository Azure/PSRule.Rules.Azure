// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data;

#nullable enable

/// <summary>
/// Defines a datastore of Azure location data.
/// </summary>
internal sealed class LocationData : ResourceLoader
{
    private const string RESOURCE_PATH = "locations.min.json.deflated";

    /// <summary>
    /// Settings for JSON deserialization.
    /// </summary>
    private static readonly JsonSerializerSettings _Settings = new()
    {
        Converters =
        [
            new ReadOnlyDictionaryConverter<AzureLocationEntry>(StringComparer.Ordinal),
        ]
    };
    private IReadOnlyDictionary<string, AzureLocationEntry>? _Index;

    public AzureLocationEntry? Get(string location)
    {
        if (location == null) throw new ArgumentNullException(nameof(location));

        return Get().TryGetValue(location, out var entry) ? entry : null;
    }

    private IReadOnlyDictionary<string, AzureLocationEntry> Get()
    {
        _Index ??= ReadIndex(GetContent(RESOURCE_PATH));
        return _Index;
    }

    private static IReadOnlyDictionary<string, AzureLocationEntry> ReadIndex(string content)
    {
        return JsonConvert.DeserializeObject<IReadOnlyDictionary<string, AzureLocationEntry>>(content, _Settings) ?? throw new JsonException(PSRuleResources.PolicyIgnoreInvalid);
    }
}

#nullable restore

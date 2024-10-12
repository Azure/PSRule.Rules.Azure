// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Threading;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// Defines a datastore of Azure resource provider data.
/// </summary>
internal sealed class ProviderData(bool useCache = true) : ResourceLoader()
{
    private const char SLASH = '/';
    private const string INDEX_PATH = "types_index.min.json.deflated";

    /// <summary>
    /// Settings for JSON deserialization.
    /// </summary>
    private static readonly JsonSerializerSettings _Settings = new()
    {
        Converters =
        [
            new TypeIndexConverter(),
            new ReadOnlyDictionaryConverter<string>(StringComparer.OrdinalIgnoreCase),
        ]
    };
    private readonly Dictionary<string, ResourceProviderType[]> _ProviderCache = useCache ? new Dictionary<string, ResourceProviderType[]>() : null;
    private TypeIndex _Index;

    public TypeIndexEntry FindResourceType(string provider, string resourceType)
    {
        return GetIndex().Resources.TryGetValue(string.Concat(provider, SLASH, resourceType), out var entry) ? entry : null;
    }

    public bool TryResourceType(TypeIndexEntry entry, out ResourceProviderType type)
    {
        return TryLoadType(entry, out type);
    }

    public bool TryResourceType(string provider, string resourceType, out ResourceProviderType type)
    {
        type = null;
        return GetIndex().Resources.TryGetValue(string.Concat(provider, SLASH, resourceType), out var entry) && TryLoadType(entry, out type);
    }

    public ResourceProviderType[] GetProviderTypes(string provider)
    {
        return ReadProviderTypes(TypeIndex.GetRelativePath(provider.ToLower(Thread.CurrentThread.CurrentCulture)));
    }

    internal TypeIndex GetIndex()
    {
        _Index ??= ReadIndex(GetContent(INDEX_PATH));
        return _Index;
    }

    private bool TryLoadType(TypeIndexEntry entry, out ResourceProviderType type)
    {
        var types = ReadProviderTypes(entry.RelativePath);
        type = types[entry.Index];
        return type != null;
    }

    /// <summary>
    /// Deserialize an index from JSON.
    /// </summary>
    private static TypeIndex ReadIndex(string content)
    {
        return JsonConvert.DeserializeObject<TypeIndex>(content, _Settings) ?? throw new JsonException(PSRuleResources.ProviderIndexInvalid);
    }

    /// <summary>
    /// Deserialize resource provider types from JSON.
    /// </summary>
    private ResourceProviderType[] ReadProviderTypes(string name)
    {
        if (_ProviderCache != null && _ProviderCache.TryGetValue(name, out var types))
            return types;

        var content = GetContent(name);
        types = JsonConvert.DeserializeObject<ResourceProviderType[]>(content, _Settings) ?? throw new JsonException(PSRuleResources.ProviderContentInvalid);
        if (_ProviderCache != null)
            _ProviderCache[name] = types;

        return types;
    }
}

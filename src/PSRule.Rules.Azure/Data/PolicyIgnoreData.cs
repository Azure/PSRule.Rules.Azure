// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data;

internal sealed class PolicyIgnoreData : ResourceLoader
{
    private const string RESOURCE_PATH = "policy-ignore.min.json.deflated";

    /// <summary>
    /// Settings for JSON deserialization.
    /// </summary>
    private static readonly JsonSerializerSettings _Settings = new()
    {
        Converters =
        [
            new PolicyIgnoreResultConverter(),
        ]
    };
    private Dictionary<string, PolicyIgnoreResult> _Index;

    internal Dictionary<string, PolicyIgnoreResult> GetIndex()
    {
        _Index ??= ReadIndex(GetContent(RESOURCE_PATH));
        return _Index;
    }

    private static Dictionary<string, PolicyIgnoreResult> ReadIndex(string content)
    {
        return JsonConvert.DeserializeObject<Dictionary<string, PolicyIgnoreResult>>(content, _Settings) ?? throw new JsonException(PSRuleResources.PolicyIgnoreInvalid);
    }
}

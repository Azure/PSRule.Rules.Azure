// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Arm;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// Defines extension methods for Azure resource provider data.
/// </summary>
internal static class ProviderDataExtensions
{
    public static bool TryResourceType(this ProviderData data, string resourceType, out ResourceProviderType type)
    {
        type = null;
        return ResourceHelper.TryResourceProviderFromType(resourceType, out var provider, out var typeName) &&
            data.TryResourceType(provider, typeName, out type);
    }
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure
{
    internal static class ResourceHelper
    {
        internal static bool IsResourceType(string resourceId, string resourceType)
        {
            if (string.IsNullOrEmpty(resourceId) || string.IsNullOrEmpty(resourceType))
                return false;

            var idParts = GetResourceIdTypeParts(resourceId);
            var typeParts = resourceType.Split('/');
            if (idParts.Length != typeParts.Length)
                return false;

            var i = 0;
            while (i < idParts.Length && i < typeParts.Length && StringComparer.OrdinalIgnoreCase.Equals(idParts[i], typeParts[i]))
                i++;

            return i == idParts.Length;
        }

        private static string[] GetResourceIdTypeParts(string resourceId)
        {
            var idParts = resourceId.Split('/');
            var i = 1;
            if (!(ConsumeSubscriptionIdPart(idParts, ref i) &&
                ConsumeResourceGroupPart(idParts, ref i) &&
                ConsumeProvidersPart(idParts, ref i, out var provider, out var type)))
                return Array.Empty<string>();

            ConsumeSubResourceType(idParts, ref i, out var subTypes);
            if (subTypes == null || subTypes.Length == 0)
                return new string[] { provider, type };

            var result = new string[2 + subTypes.Length];
            result[0] = provider;
            result[1] = type;
            Array.Copy(subTypes, 0, result, 2, subTypes.Length);
            return result;
        }

        private static bool ConsumeSubscriptionIdPart(string[] parts, ref int start)
        {
            if (!(start + 1 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], "subscriptions")))
                return false;

            start += 2;
            return true;
        }

        private static bool ConsumeResourceGroupPart(string[] parts, ref int start)
        {
            if (!(start + 1 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], "resourceGroups")))
                return false;

            start += 2;
            return true;
        }

        private static bool ConsumeProvidersPart(string[] parts, ref int start, out string provider, out string type)
        {
            provider = null;
            type = null;
            if (!(start + 3 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], "providers")))
                return false;

            provider = parts[start + 1];
            type = parts[start + 2];
            start += 4;
            return true;
        }

        private static bool ConsumeSubResourceType(string[] parts, ref int start, out string[] subTypes)
        {
            subTypes = null;
            var remaining = parts.Length - start;
            if (!(start + 1 < parts.Length && remaining % 2 == 0))
                return false;

            subTypes = new string[remaining / 2];
            for (var i = 0; start < parts.Length; i += 2)
            {
                subTypes[i] = parts[start];
                start += 2;
            }
            return true;
        }
    }
}

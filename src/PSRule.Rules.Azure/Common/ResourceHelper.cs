// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure
{
    internal static class ResourceHelper
    {
        private const string SLASH = "/";
        private const string SUBSCRIPTIONS = "subscriptions";
        private const string RESOURCEGROUPS = "resourceGroups";
        private const string PROVIDERS = "providers";

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

        /// <summary>
        /// 
        /// </summary>
        /// <remarks>
        /// /subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/{resourceType}/{name}
        /// /subscriptions/{subscriptionId}/providers/{resourceType}/{name}
        /// /providers/{resourceType}/{name}
        /// </remarks>
        internal static string CombineResourceId(string subscriptionId, string resourceGroup, string[] resourceType, string[] name, int depth = int.MaxValue)
        {
            if (resourceType.Length != name.Length)
                throw new TemplateFunctionException(nameof(resourceType), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

            var parts = 1 + resourceType.Length + name.Length;
            parts += subscriptionId != null ? 2 : 0;
            parts += resourceGroup != null ? 2 : 0;

            var result = new string[parts * 2];
            var i = 0;
            var j = 0;

            if (subscriptionId != null)
            {
                result[i++] = SLASH;
                result[i++] = SUBSCRIPTIONS;
                result[i++] = SLASH;
                result[i++] = subscriptionId;
            }
            if (resourceGroup != null)
            {
                result[i++] = SLASH;
                result[i++] = RESOURCEGROUPS;
                result[i++] = SLASH;
                result[i++] = resourceGroup;
            }
            result[i++] = SLASH;
            result[i++] = PROVIDERS;
            while (i < result.Length && j <= depth)
            {
                result[i++] = SLASH;
                result[i++] = resourceType[j];
                result[i++] = SLASH;
                result[i++] = name[j++];
            }
            return string.Concat(result);
        }

        internal static string CombineResourceId(string subscriptionId, string resourceGroup, string resourceType, string name)
        {
            TryResourceIdComponents(resourceType, name, out var typeComponents, out var nameComponents);
            return CombineResourceId(subscriptionId, resourceGroup, typeComponents, nameComponents);
        }

        internal static bool TryResourceIdComponents(string resourceType, string name, out string[] resourceTypeComponents, out string[] nameComponents)
        {
            var typeParts = resourceType.Split('/');
            var depth = string.IsNullOrEmpty(typeParts[typeParts.Length - 1]) ? typeParts.Length - 2 : typeParts.Length - 1;
            resourceTypeComponents = new string[depth];
            resourceTypeComponents[0] = string.Concat(typeParts[0], '/', typeParts[1]);
            for (var i = 1; i < depth; i++)
                resourceTypeComponents[i] = typeParts[i + 1];

            nameComponents = name.Split('/');
            return resourceTypeComponents.Length > 0 && nameComponents.Length > 0;
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
            if (!(start + 1 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], SUBSCRIPTIONS)))
                return false;

            start += 2;
            return true;
        }

        private static bool ConsumeResourceGroupPart(string[] parts, ref int start)
        {
            if (!(start + 1 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], RESOURCEGROUPS)))
                return false;

            start += 2;
            return true;
        }

        private static bool ConsumeProvidersPart(string[] parts, ref int start, out string provider, out string type)
        {
            provider = null;
            type = null;
            if (!(start + 3 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], PROVIDERS)))
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

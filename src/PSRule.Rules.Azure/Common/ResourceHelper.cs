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
            var resourceTypeLength = resourceType?.Length ?? 0;
            var nameLength = name?.Length ?? 0;
            if (resourceTypeLength != nameLength)
                throw new TemplateFunctionException(nameof(resourceType), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

            var parts = resourceTypeLength + nameLength;
            parts += parts > 0 ? 1 : 0;
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
            if (resourceTypeLength > 0 && depth >= 0)
            {
                result[i++] = SLASH;
                result[i++] = PROVIDERS;
                while (i < result.Length && j <= depth)
                {
                    result[i++] = SLASH;
                    result[i++] = resourceType[j];
                    result[i++] = SLASH;
                    result[i++] = name[j++];
                }
            }
            return string.Concat(result);
        }

        internal static string CombineResourceId(string subscriptionId, string resourceGroup, string resourceType, string name, int depth = int.MaxValue)
        {
            TryResourceIdComponents(resourceType, name, out var typeComponents, out var nameComponents);
            return CombineResourceId(subscriptionId, resourceGroup, typeComponents, nameComponents, depth);
        }

        internal static string GetParentResourceId(string subscriptionId, string resourceGroup, string[] resourceType, string[] name)
        {
            var depth = resourceType.Length - 2;
            if (resourceType.Length >= 3 && StringComparer.OrdinalIgnoreCase.Equals(resourceType[1], PROVIDERS))
                depth--;

            return CombineResourceId(subscriptionId, resourceGroup, resourceType, name, depth);
        }

        internal static string GetParentResourceId(string subscriptionId, string resourceGroup, string resourceType, string name)
        {
            TryResourceIdComponents(resourceType, name, out var typeComponents, out var nameComponents);
            var depth = typeComponents.Length - 2;
            if (typeComponents.Length >= 3 && StringComparer.OrdinalIgnoreCase.Equals(typeComponents[1], PROVIDERS))
                depth--;

            return CombineResourceId(subscriptionId, resourceGroup, typeComponents, nameComponents, depth);
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

        internal static bool TryResourceIdComponents(string resourceId, out string subscriptionId, out string resourceGroupName, out string[] resourceTypeComponents, out string[] nameComponents)
        {
            resourceGroupName = null;
            resourceTypeComponents = null;
            nameComponents = null;
            var idParts = resourceId.Split('/');
            var i = 0;
            if (!(ConsumeSubscriptionIdPart(idParts, ref i, out subscriptionId) &&
                ConsumeResourceGroupPart(idParts, ref i, out resourceGroupName) &&
                ConsumeProvidersPart(idParts, ref i, out var provider, out var type, out var name)))
                return false;

            var resourceType = string.Concat(provider, '/', type);
            if (!ConsumeSubResourceType(idParts, ref i, out var subTypes, out var subNames))
            {
                resourceTypeComponents = new string[] { resourceType };
                nameComponents = new string[] { name };
                return true;
            }

            resourceTypeComponents = new string[subTypes.Length + 1];
            resourceTypeComponents[0] = resourceType;
            Array.Copy(subTypes, 0, resourceTypeComponents, 1, subTypes.Length);

            nameComponents = new string[subNames.Length + 1];
            nameComponents[0] = name;
            Array.Copy(subNames, 0, nameComponents, 1, subNames.Length);
            return true;
        }

        private static string[] GetResourceIdTypeParts(string resourceId)
        {
            var idParts = resourceId.Split('/');
            var i = 0;
            if (!(ConsumeSubscriptionIdPart(idParts, ref i, out _) &&
                ConsumeResourceGroupPart(idParts, ref i, out _) &&
                ConsumeProvidersPart(idParts, ref i, out var provider, out var type, out _)))
                return Array.Empty<string>();

            ConsumeSubResourceType(idParts, ref i, out var subTypes, out _);
            if (subTypes == null || subTypes.Length == 0)
                return new string[] { provider, type };

            var result = new string[2 + subTypes.Length];
            result[0] = provider;
            result[1] = type;
            Array.Copy(subTypes, 0, result, 2, subTypes.Length);
            return result;
        }

        private static bool ConsumeSubscriptionIdPart(string[] parts, ref int start, out string subscriptionId)
        {
            subscriptionId = null;
            if (start + 2 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start + 1], SUBSCRIPTIONS))
            {
                subscriptionId = parts[start + 2];
                start += 3;
            }
            return true;
        }

        private static bool ConsumeResourceGroupPart(string[] parts, ref int start, out string resourceGroupName)
        {
            resourceGroupName = null;
            if (start + 1 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], RESOURCEGROUPS))
            {
                resourceGroupName = parts[start + 1];
                start += 2;
            }
            return true;
        }

        private static bool ConsumeProvidersPart(string[] parts, ref int start, out string provider, out string type, out string name)
        {
            provider = null;
            type = null;
            name = null;
            if (start + 2 >= parts.Length)
                return false;

            if (start + 3 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], PROVIDERS))
                start++;

            provider = parts[start++];
            type = parts[start++];
            name = parts[start++];
            return true;
        }

        private static bool ConsumeSubResourceType(string[] parts, ref int start, out string[] subTypes, out string[] subNames)
        {
            subTypes = null;
            subNames = null;
            var remaining = parts.Length - start;
            if (!(start + 1 < parts.Length && remaining % 2 == 0))
                return false;

            subTypes = new string[remaining / 2];
            subNames = new string[remaining / 2];
            for (var i = 0; start < parts.Length; i++)
            {
                subTypes[i] = parts[start];
                subNames[i] = parts[start + 1];
                start += 2;
            }
            return true;
        }
    }
}

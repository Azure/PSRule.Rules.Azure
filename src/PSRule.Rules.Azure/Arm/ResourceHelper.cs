// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Arm.Expressions;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Resources;

#nullable enable

namespace PSRule.Rules.Azure.Arm;

internal static class ResourceHelper
{
    private const string SLASH = "/";
    private const string DOT = ".";
    private const string SUBSCRIPTIONS = "subscriptions";
    private const string RESOURCE_GROUPS = "resourceGroups";
    private const string MANAGEMENT_GROUPS = "managementGroups";
    private const string PROVIDERS = "providers";
    private const string MANAGEMENT_GROUP_TYPE = "/providers/Microsoft.Management/managementGroups/";
    private const string PROVIDER_MICROSOFT_MANAGEMENT = "Microsoft.Management";

    private const char SLASH_C = '/';

    /// <summary>
    /// Determines if the resource Id matches the specified resource type.
    /// </summary>
    /// <param name="resourceId">The resource Id to compare.</param>
    /// <param name="resourceType">The expected resource type.</param>
    /// <returns>Returns <c>true</c> if the resource Id matches the type. Otherwise <c>false</c> is returned.</returns>
    internal static bool IsResourceType(string resourceId, string resourceType)
    {
        if (string.IsNullOrEmpty(resourceId) || string.IsNullOrEmpty(resourceType))
            return false;

        var idParts = GetResourceIdTypeParts(resourceId);
        var typeParts = resourceType.Split(SLASH_C);
        if (idParts.Length != typeParts.Length)
            return false;

        var i = 0;
        while (i < idParts.Length && i < typeParts.Length && StringComparer.OrdinalIgnoreCase.Equals(idParts[i], typeParts[i]))
            i++;

        return i == idParts.Length;
    }

    /// <summary>
    /// Determines if the string is a valid resource Id.
    /// </summary>
    internal static bool IsResourceId(string? s)
    {
        if (s == null || string.IsNullOrWhiteSpace(s))
            return false;

        return s == SLASH || TrySubscriptionId(s, out _) || TryManagementGroup(s, out _) || TryTenantResourceProvider(s, out _, out _, out _);
    }

    /// <summary>
    /// Determine if the resource type is a sub-resource of the parent resource Id.
    /// </summary>
    /// <param name="parentId">The resource Id of the parent resource.</param>
    /// <param name="resourceType">The resource type of sub-resource.</param>
    /// <returns>Returns <c>true</c> if the resource type is a sub-resource. Otherwise <c>false</c> is returned.</returns>
    internal static bool IsSubResourceType(string parentId, string resourceType)
    {
        if (string.IsNullOrWhiteSpace(parentId) || string.IsNullOrWhiteSpace(resourceType))
            return false;

        // Is the resource type has no provider namespace dot it is a sub type.
        if (!resourceType.Contains(DOT)) return true;

        // Compare full type names.
        var parentType = GetResourceType(parentId);
        return resourceType.StartsWith(parentType, StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Get the resource type of the resource.
    /// </summary>
    /// <param name="resourceId">The resource Id of a resource.</param>
    /// <returns>Returns the resource type if the Id is valid or <c>null</c> when an invalid resource Id is specified.</returns>
    internal static string? GetResourceType(string? resourceId)
    {
        return resourceId == null || string.IsNullOrEmpty(resourceId) ? null : string.Join(SLASH, GetResourceIdTypeParts(resourceId));
    }

    /// <summary>
    /// Get the resource provider namespaces and type from a full resource type string.
    /// </summary>
    internal static bool TryResourceProviderFromType(string type, out string? provider, out string? resourceType)
    {
        provider = null;
        resourceType = null;
        var parts = type.SplitByFirstSubstring("/");
        if (parts.Length != 2)
            return false;

        provider = parts[0];
        resourceType = parts[1];
        return true;
    }

    /// <summary>
    /// Get the subscription Id from a specified resource Id.
    /// </summary>
    internal static bool TrySubscriptionId(string resourceId, out string? subscriptionId)
    {
        subscriptionId = null;
        if (string.IsNullOrEmpty(resourceId))
            return false;

        var idParts = resourceId.Split(SLASH_C);
        var i = 0;
        return TryConsumeSubscriptionIdPart(idParts, ref i, out subscriptionId);
    }

    /// <summary>
    /// Get the name of the resource group from the specified resource Id.
    /// </summary>
    internal static bool TryResourceGroup(string resourceId, out string? subscriptionId, out string? resourceGroupName)
    {
        subscriptionId = null;
        resourceGroupName = null;
        if (string.IsNullOrEmpty(resourceId))
            return false;

        var idParts = resourceId.Split(SLASH_C);
        var i = 0;
        return TryConsumeSubscriptionIdPart(idParts, ref i, out subscriptionId) &&
            TryConsumeResourceGroupPart(idParts, ref i, out resourceGroupName);
    }

    /// <summary>
    /// Get the name of the management group from the specified resource Id.
    /// </summary>
    internal static bool TryManagementGroup(string resourceId, out string? managementGroup)
    {
        managementGroup = null;
        if (string.IsNullOrEmpty(resourceId))
            return false;

        var idParts = resourceId.Split(SLASH_C);
        var i = 0;
        return TryConsumeManagementGroupPart(idParts, ref i, out managementGroup);
    }

    /// <summary>
    /// Get the resource type and name from the specified resource Id from a tenant scope.
    /// </summary>
    internal static bool TryTenantResourceProvider(string resourceId, out string? provider, out string[]? type, out string[]? name)
    {
        provider = null;
        type = null;
        name = null;
        if (string.IsNullOrWhiteSpace(resourceId) || resourceId == SLASH)
            return false;

        var idParts = resourceId.Split(SLASH_C);
        var i = 0;
        if (TryConsumeTenantPart(idParts, ref i, out _))
        {
            _ = TryConsumeProviderPart(idParts, ref i, out provider, out type, out name);
            return true;
        }
        return false;
    }

    /// <summary>
    /// Combines Id fragments to form a resource Id.
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
        parts += subscriptionId != null ? 2 : 0;
        parts += resourceGroup != null ? 2 : 0;

        for (var p = 0; resourceType != null && p < resourceType.Length; p++)
        {
            if (resourceType[p].Contains(DOT))
                parts++;
        }

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
            result[i++] = RESOURCE_GROUPS;
            result[i++] = SLASH;
            result[i++] = resourceGroup;
        }
        if (resourceTypeLength > 0 && depth >= 0)
        {
            while (i < result.Length && j <= depth)
            {
                // If a resource provider is included prepend /providers.
                if (resourceType[j].Contains(DOT))
                {
                    result[i++] = SLASH;
                    result[i++] = PROVIDERS;
                }

                result[i++] = SLASH;
                result[i++] = resourceType[j];
                result[i++] = SLASH;
                result[i++] = name[j++];
            }
        }
        return string.Concat(result);
    }

    internal static string CombineResourceId(string subscriptionId, string resourceGroup, string resourceType, string name, int depth = int.MaxValue, string? scope = null)
    {
        TryResourceIdComponents(resourceType, name, out var typeComponents, out var nameComponents);

        // Handle scoped resource IDs.
        if (!string.IsNullOrEmpty(scope) && scope != null && scope != SLASH && TryResourceIdComponents(scope, out subscriptionId, out resourceGroup, out var parentTypeComponents, nameComponents: out var parentNameComponents))
        {
            typeComponents = MergeResourceNameOrType(parentTypeComponents, typeComponents);
            nameComponents = MergeResourceNameOrType(parentNameComponents, nameComponents);
        }
        return CombineResourceId(subscriptionId, resourceGroup, typeComponents, nameComponents, depth);
    }

    internal static string ResourceId(string resourceType, string resourceName, string? scopeId, int depth = int.MaxValue)
    {
        var typeParts = GetResourceTypeParts(resourceType);
        var nameParts = resourceName.Split(SLASH_C);
        return ResourceId(typeParts, nameParts, scopeId, depth);
    }

    internal static string ResourceId(string[]? resourceType, string[]? resourceName, string? scopeId, int depth = int.MaxValue)
    {
        return ResourceId(tenant: null, managementGroup: null, subscriptionId: null, resourceGroup: null, resourceType, resourceName, scopeId, depth);
    }

    internal static string ResourceId(string? tenant, string? managementGroup, string? subscriptionId, string? resourceGroup, string resourceType, string resourceName, string? scopeId, int depth = int.MaxValue)
    {
        var typeParts = GetResourceTypeParts(resourceType);
        var nameParts = resourceName.Split(SLASH_C);
        return ResourceId(tenant, managementGroup, subscriptionId, resourceGroup, typeParts, nameParts, scopeId, depth);
    }

    internal static string ResourceId(string? tenant, string? managementGroup, string? subscriptionId, string? resourceGroup, string[]? resourceTypeParts, string[]? resourceNameParts, string? scopeId, int depth = int.MaxValue)
    {
        var resourceTypeLength = resourceTypeParts?.Length ?? 0;
        var nameLength = resourceNameParts?.Length ?? 0;
        if (resourceTypeLength != nameLength)
            throw new TemplateFunctionException(nameof(resourceTypeParts), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

        if (!ResourceIdComponents(scopeId, out var scopeTenant, out var scopeManagementGroup, out var scopeSubscriptionId, out var scopeResourceGroup, out var scopeResourceType, out var scopeResourceName))
        {
            scopeResourceType = null;
            scopeResourceName = null;
        }

        resourceTypeParts = MergeResourceNameOrType(scopeResourceType, resourceTypeParts);
        resourceNameParts = MergeResourceNameOrType(scopeResourceName, resourceNameParts);
        return ResourceId(scopeTenant ?? tenant, scopeManagementGroup ?? managementGroup, scopeSubscriptionId ?? subscriptionId, scopeResourceGroup ?? resourceGroup, resourceTypeParts, resourceNameParts, depth);
    }

    internal static string ResourceGroupId(string subscriptionId, string resourceGroup)
    {
        return string.Format("/subscriptions/{0}/resourceGroups/{1}", subscriptionId, resourceGroup);
    }

    private static string[]? MergeResourceNameOrType(string[]? parentNameOrType, string[]? nameOrType)
    {
        if (parentNameOrType == null || parentNameOrType.Length == 0) return nameOrType;
        if (nameOrType == null || nameOrType.Length == 0) return parentNameOrType;

        var result = new string[parentNameOrType.Length + nameOrType.Length];

        // Complete the resource name or type without duplicating similar segments.
        var i = 0;
        var j = 0;
        var size = 0;
        while (i < parentNameOrType.Length && j < nameOrType.Length)
        {
            if (string.Equals(parentNameOrType[i], nameOrType[j], StringComparison.OrdinalIgnoreCase))
                j++;

            result[i] = parentNameOrType[i];
            i++;
            size++;
        }

        // Add remaining segments.
        while (i < parentNameOrType.Length)
        {
            result[i] = parentNameOrType[i];
            i++;
            size++;
        }

        while (j < nameOrType.Length)
        {
            result[i] = nameOrType[j];
            i++;
            j++;
            size++;
        }

        if (size < result.Length)
        {
            Array.Resize(ref result, size);
        }

        return result;

    }

    /// <summary>
    /// Get a resource ID from the components.
    /// </summary>
    /// <remarks>
    /// /subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/{resourceType}/{name}
    /// /subscriptions/{subscriptionId}/providers/{resourceType}/{name}
    /// /providers/Microsoft.Management/managementGroups/mg1/providers/{resourceType}/{name}
    /// /providers/{resourceType}/{name}
    /// </remarks>
    internal static string ResourceId(string? scopeTenant, string? scopeManagementGroup, string? scopeSubscriptionId, string? scopeResourceGroup, string[]? resourceType, string[]? resourceName, int depth = int.MaxValue)
    {
        var resourceTypeLength = resourceType?.Length ?? 0;
        var nameLength = resourceName?.Length ?? 0;
        if (resourceTypeLength != nameLength)
            throw new TemplateFunctionException(nameof(resourceType), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

        // Coalesce depth.
        var actualDepth = ResourceIdDepth(scopeTenant, scopeManagementGroup, scopeSubscriptionId, scopeResourceGroup, resourceType, resourceName);
        depth = depth < 0 ? actualDepth + depth : depth > actualDepth ? actualDepth : depth;

        var parts = scopeTenant == SLASH ? 1 : scopeSubscriptionId != null ? 4 : scopeManagementGroup != null ? 8 : 0;
        parts += scopeResourceGroup != null ? 4 : 0;
        parts += depth >= resourceTypeLength ? resourceTypeLength * 4 : depth * 4;

        // Add additional provider segments.
        for (var p = 0; resourceType != null && p < resourceType.Length; p++)
        {
            if (resourceType[p].Contains(DOT))
                parts += 2;
        }

        var result = new string[parts];
        var i = 0;
        var j = 0;
        var currentDepth = 0;

        if (scopeTenant == null && scopeManagementGroup != null && depth >= 1)
        {
            result[i++] = SLASH;
            result[i++] = PROVIDERS;
            result[i++] = SLASH;
            result[i++] = PROVIDER_MICROSOFT_MANAGEMENT;
            result[i++] = SLASH;
            result[i++] = MANAGEMENT_GROUPS;
            result[i++] = SLASH;
            result[i++] = scopeManagementGroup;
            currentDepth++;
        }
        else if (scopeTenant == null && scopeSubscriptionId != null && depth >= 1)
        {
            result[i++] = SLASH;
            result[i++] = SUBSCRIPTIONS;
            result[i++] = SLASH;
            result[i++] = scopeSubscriptionId;
            currentDepth++;

            if (scopeResourceGroup != null && depth >= 2)
            {
                result[i++] = SLASH;
                result[i++] = RESOURCE_GROUPS;
                result[i++] = SLASH;
                result[i++] = scopeResourceGroup;
                currentDepth++;
            }
        }

        // Handle resource type and name.
        if (depth > currentDepth && resourceType != null && resourceName != null && resourceTypeLength > 0)
        {
            while (i < result.Length && depth > currentDepth && j < resourceTypeLength)
            {
                // If a resource provider is included providers segment.
                if (resourceType[j].Contains(DOT))
                {
                    result[i++] = SLASH;
                    result[i++] = PROVIDERS;
                }

                // Don't increment when providers is already in the type segment.
                if (!string.Equals(resourceType[j], PROVIDERS, StringComparison.OrdinalIgnoreCase))
                    currentDepth++;

                result[i++] = SLASH;
                result[i++] = resourceType[j];
                result[i++] = SLASH;
                result[i++] = resourceName[j++];
            }
        }

        return scopeTenant != null && i == 0 ? SLASH : string.Concat(result);
    }

    /// <summary>
    /// From the resource ID extract out the components.
    /// </summary>
    internal static bool ResourceIdComponents(string? resourceId, out string? tenant, out string? managementGroup, out string? subscriptionId, out string? resourceGroup, out string[]? resourceType, out string[]? resourceName)
    {
        tenant = null;
        managementGroup = null;
        subscriptionId = null;
        resourceGroup = null;
        resourceType = null;
        resourceName = null;

        if (string.IsNullOrEmpty(resourceId))
            return false;

        var idParts = resourceId!.Split(SLASH_C);
        var i = 0;
        if (TryConsumeSubscriptionIdPart(idParts, ref i, out subscriptionId))
        {
            if (TryConsumeResourceGroupPart(idParts, ref i, out resourceGroup))
            {
                _ = TryConsumeProviderPart(idParts, ref i, out _, out resourceType, out resourceName);
            }
            return true;
        }

        if (TryConsumeManagementGroupPart(idParts, ref i, out managementGroup))
        {
            _ = TryConsumeProviderPart(idParts, ref i, out _, out resourceType, out resourceName);
            return true;
        }

        if (TryConsumeTenantPart(idParts, ref i, out tenant))
        {
            _ = TryConsumeProviderPart(idParts, ref i, out _, out resourceType, out resourceName);
            return true;
        }

        return TryConsumeProviderPart(idParts, ref i, out _, out resourceType, out resourceName);
    }

    /// <summary>
    /// Get the depth of a specific resource ID based on split out components.
    /// </summary>
    /// <returns>Returns the depth of the resource ID where tenant scope is always <c>0</c>. Management group or subscriptions scopes are depth <c>1</c>.</returns>
    internal static int ResourceIdDepth(string? scopeTenant, string? scopeManagementGroup, string? scopeSubscriptionId, string? scopeResourceGroup, string[]? resourceType, string[]? resourceName)
    {
        var depth = scopeTenant == SLASH || (string.IsNullOrEmpty(scopeManagementGroup) && string.IsNullOrEmpty(scopeSubscriptionId)) ? 0 : 1;
        if (!string.IsNullOrEmpty(scopeSubscriptionId) && !string.IsNullOrEmpty(scopeResourceGroup))
            depth++;

        if (resourceType != null && resourceName != null)
            depth += ResourceNameOrTypeDepth(resourceType);

        return depth;
    }

    internal static int ResourceNameOrTypeDepth(string[] nameOrType)
    {
        var depth = 0;
        for (var i = 0; i < nameOrType.Length; i++)
        {
            if (!string.Equals(nameOrType[i], PROVIDERS, StringComparison.OrdinalIgnoreCase))
                depth++;
        }
        return depth;
    }

    private static string[] GetResourceTypeParts(string resourceType)
    {
        var parts = resourceType.Split(SLASH_C);
        var result = new string[parts.Length - 1];

        if (parts.Length < 2) throw new ArgumentException(nameof(resourceType));
        if (parts.Length == 2) return [resourceType];

        result[0] = string.Concat(parts[0], SLASH, parts[1]);
        Array.Copy(parts, 2, result, 1, parts.Length - 2);
        return result;
    }

    /// <summary>
    /// Combines Id fragments to form a resource Id at a management group scope.
    /// </summary>
    /// <remarks>
    /// /providers/Microsoft.Management/managementGroups/{managementGroupName}/providers/{resourceType}/{resourceName}
    /// </remarks>
    internal static string CombineResourceId(string managementGroupName, string[] resourceType, string[] name, int depth = int.MaxValue)
    {
        var resourceTypeLength = resourceType?.Length ?? 0;
        var nameLength = name?.Length ?? 0;
        if (resourceTypeLength != nameLength)
            throw new TemplateFunctionException(nameof(resourceType), FunctionErrorType.MismatchingResourceSegments, PSRuleResources.MismatchingResourceSegments);

        var parts = resourceTypeLength + nameLength + 2;
        var result = new string[parts * 2];
        var i = 0;
        var j = 0;

        result[i++] = MANAGEMENT_GROUP_TYPE;
        result[i++] = managementGroupName;
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

    internal static string GetParentResourceId(string subscriptionId, string resourceGroup, string[] resourceType, string[] resourceName)
    {
        return ResourceId
        (
            scopeTenant: null,
            scopeManagementGroup: null,
            scopeSubscriptionId: subscriptionId,
            scopeResourceGroup: resourceGroup,
            resourceType: resourceType,
            resourceName: resourceName,
            depth: -1
        );
    }

    internal static string GetParentResourceId(string subscriptionId, string resourceGroup, string resourceType, string name)
    {
        TryResourceIdComponents(resourceType, name, out var typeComponents, out var nameComponents);
        var depth = typeComponents.Length - 2;
        if (typeComponents.Length >= 3 && StringComparer.OrdinalIgnoreCase.Equals(typeComponents[1], PROVIDERS))
            depth--;

        return CombineResourceId(subscriptionId, resourceGroup, typeComponents, nameComponents, depth);
    }

    internal static bool TryResourceIdComponents(string resourceId, out string? subscriptionId, out string? resourceGroupName, out string? resourceType, out string? name)
    {
        resourceType = null;
        name = null;
        if (!TryResourceIdComponents(resourceId, out subscriptionId, out resourceGroupName, out string[]? resourceTypeComponents, out string[]? nameComponents))
            return false;

        resourceType = string.Join(SLASH, resourceTypeComponents);
        name = string.Join(SLASH, nameComponents);
        return true;
    }

    internal static bool TryResourceIdComponents(string resourceType, string name, out string[] resourceTypeComponents, out string[] nameComponents)
    {
        var typeParts = resourceType.Split(SLASH_C);
        var depth = string.IsNullOrEmpty(typeParts[typeParts.Length - 1]) ? typeParts.Length - 2 : typeParts.Length - 1;
        resourceTypeComponents = new string[depth];
        resourceTypeComponents[0] = string.Concat(typeParts[0], SLASH_C, typeParts[1]);
        for (var i = 1; i < depth; i++)
            resourceTypeComponents[i] = typeParts[i + 1];

        nameComponents = name.Split(SLASH_C);
        return resourceTypeComponents.Length > 0 && nameComponents.Length > 0;
    }

    internal static bool TryResourceIdComponents(string resourceId, out string? subscriptionId, out string? resourceGroupName, out string[]? resourceTypeComponents, out string[]? nameComponents)
    {
        resourceGroupName = null;
        resourceTypeComponents = null;
        nameComponents = null;
        var idParts = resourceId.Split(SLASH_C);
        var i = 0;
        if (!(ConsumeSubscriptionIdPartOrNull(idParts, ref i, out subscriptionId) &&
            ConsumeResourceGroupPartOrNull(idParts, ref i, out resourceGroupName) &&
            TryConsumeProviderPartOld(idParts, ref i, out var provider, out var type, out var name)))
            return false;

        var resourceType = string.Concat(provider, SLASH_C, type);
        if (!TryConsumeResourceType(idParts, ref i, out var subTypes, out var subNames))
        {
            resourceTypeComponents = [resourceType];
            nameComponents = [name];
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
        var idParts = resourceId.Split(SLASH_C);
        var i = 0;
        if (!(ConsumeSubscriptionIdPartOrNull(idParts, ref i, out _) &&
            ConsumeResourceGroupPartOrNull(idParts, ref i, out _) &&
            TryConsumeProviderPartOld(idParts, ref i, out var provider, out var type, out _)))
            return [];

        TryConsumeResourceType(idParts, ref i, out var subTypes, out _);
        if (subTypes == null || subTypes.Length == 0)
            return [provider, type];

        var result = new string[2 + subTypes.Length];
        result[0] = provider;
        result[1] = type;
        Array.Copy(subTypes, 0, result, 2, subTypes.Length);
        return result;
    }

    private static bool ConsumeSubscriptionIdPartOrNull(string[] parts, ref int start, out string? subscriptionId)
    {
        TryConsumeSubscriptionIdPart(parts, ref start, out subscriptionId);
        return true;
    }

    /// <summary>
    /// Get the subscription component of the resource ID parts.
    /// </summary>
    /// <param name="parts">The parts of a resource ID split by <c>/</c>.</param>
    /// <param name="start">The index to start from.</param>
    /// <param name="subscriptionId">Returns the <c>subscriptionId</c>.</param>
    /// <returns>Returns <c>true</c> if the subscription component was found.</returns>
    private static bool TryConsumeSubscriptionIdPart(string[] parts, ref int start, out string? subscriptionId)
    {
        subscriptionId = null;
        if (start + 2 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start + 1], SUBSCRIPTIONS))
        {
            subscriptionId = parts[start + 2];
            start += 3;
        }
        return subscriptionId != null;
    }

    /// <summary>
    /// Get the resource group component of the resource ID parts.
    /// </summary>
    /// <param name="parts">The parts of a resource ID split by <c>/</c>.</param>
    /// <param name="start">The index to start from.</param>
    /// <param name="resourceGroupName">Returns the <c>resourceGroupName</c>.</param>
    /// <returns>Returns <c>true</c> if the resource group component was found.</returns>
    private static bool TryConsumeResourceGroupPart(string[] parts, ref int start, out string? resourceGroupName)
    {
        resourceGroupName = null;
        if (start + 1 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], RESOURCE_GROUPS))
        {
            resourceGroupName = parts[start + 1];
            start += 2;
        }
        return resourceGroupName != null;
    }

    private static bool ConsumeResourceGroupPartOrNull(string[] parts, ref int start, out string? resourceGroupName)
    {
        TryConsumeResourceGroupPart(parts, ref start, out resourceGroupName);
        return true;
    }

    private static bool TryConsumeTenantPart(string[] idParts, ref int start, out string? tenant)
    {
        tenant = null;
        if (start == 0 && idParts.Length >= 2 && idParts[0] == string.Empty && (idParts[1] == string.Empty || StringComparer.OrdinalIgnoreCase.Equals(idParts[1], PROVIDERS)))
        {
            tenant = SLASH;
            start += 1;
            return true;
        }
        return false;
    }

    private static bool TryConsumeManagementGroupPart(string[] idParts, ref int start, out string? managementGroup)
    {
        managementGroup = null;
        // Handle ID form: /providers/Microsoft.Management/managementGroups/<name>
        if (start == 0 && idParts.Length >= 5 && idParts[0] == string.Empty && StringComparer.OrdinalIgnoreCase.Equals(idParts[1], PROVIDERS) && idParts[2] == PROVIDER_MICROSOFT_MANAGEMENT && idParts[3] == MANAGEMENT_GROUPS)
        {
            managementGroup = idParts[4];
            start += 5;
            return true;
        }
        // Handle scope form: Microsoft.Management/managementGroups/<name>
        else if (start == 0 && idParts.Length >= 3 && idParts[0] == PROVIDER_MICROSOFT_MANAGEMENT && idParts[1] == MANAGEMENT_GROUPS)
        {
            managementGroup = idParts[2];
            start += 3;
            return true;
        }
        return false;
    }

    private static bool TryConsumeProviderPartOld(string[] parts, ref int start, out string? provider, out string? type, out string? name)
    {
        provider = null;
        type = null;
        name = null;
        if (start + 2 >= parts.Length)
            return false;

        if (start + 3 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], PROVIDERS))
            start++;

        if (start == 0 && StringComparer.OrdinalIgnoreCase.Equals(parts[1], PROVIDERS))
            start += 2;

        provider = parts[start++];
        type = parts[start++];
        name = parts[start++];
        return true;
    }

    private static bool TryConsumeProviderPart(string[] parts, ref int start, out string? provider, out string[]? type, out string[]? name)
    {
        provider = null;
        type = null;
        name = null;

        if (start + 2 >= parts.Length)
            return false;

        if (start + 3 < parts.Length && StringComparer.OrdinalIgnoreCase.Equals(parts[start], PROVIDERS))
            start++;

        if (start == 0 && StringComparer.OrdinalIgnoreCase.Equals(parts[1], PROVIDERS))
            start += 2;

        provider = parts[start++];
        var remaining = parts.Length - start;
        type = new string[remaining / 2];
        name = new string[remaining / 2];
        for (var i = 0; start < parts.Length; i++)
        {
            type[i] = i == 0 ? string.Concat(provider, SLASH, parts[start++]) : parts[start++];
            name[i] = parts[start++];
        }

        return true;
    }

    private static bool TryConsumeResourceType(string[] parts, ref int start, out string[]? type, out string[]? name)
    {
        type = null;
        name = null;
        var remaining = parts.Length - start;
        if (!(start + 1 < parts.Length && remaining % 2 == 0))
            return false;

        type = new string[remaining / 2];
        name = new string[remaining / 2];
        for (var i = 0; start < parts.Length; i++)
        {
            type[i] = parts[start];
            name[i] = parts[start + 1];
            start += 2;
        }
        return true;
    }
}

#nullable restore

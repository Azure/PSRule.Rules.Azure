// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm;
using PSRule.Rules.Azure.Arm.Policy;

namespace PSRule.Rules.Azure.Pipeline.Export;

/// <summary>
/// A visitor to expand policy assignment data.
/// </summary>
internal sealed class PolicyAssignmentExpandVisitor
{
    private const string PROPERTY_ID = "id";
    private const string PROPERTY_TYPE = "type";
    private const string PROPERTY_IDENTITY = "identity";
    private const string PROPERTY_LOCATION = "location";
    private const string PROPERTY_PROPERTIES = "properties";
    private const string PROPERTY_SCOPE = "scope";
    private const string PROPERTY_EXEMPTIONS = "exemptions";
    private const string PROPERTY_SYSTEM_DATA = "systemData";
    private const string PROPERTY_METADATA = "metadata";
    private const string PROPERTY_CREATED_BY = "createdBy";
    private const string PROPERTY_CREATED_BY_TYPE = "createdByType";
    private const string PROPERTY_CREATED_ON = "createdOn";
    private const string PROPERTY_UPDATED_BY = "updatedBy";
    private const string PROPERTY_UPDATED_ON = "updatedOn";
    private const string PROPERTY_LAST_MODIFIED_BY = "lastModifiedBy";
    private const string PROPERTY_LAST_MODIFIED_BY_TYPE = "lastModifiedByType";
    private const string PROPERTY_LAST_MODIFIED_AT = "lastModifiedAt";
    private const string PROPERTY_POLICY_DEFINITION_ID = "policyDefinitionId";
    private const string PROPERTY_POLICY_DEFINITIONS = "policyDefinitions";
    private const string TYPE_POLICY_ASSIGNMENT = "Microsoft.Authorization/policyAssignments";
    private const string TYPE_POLICY_DEFINITION = "Microsoft.Authorization/policyDefinitions";
    private const string TYPE_POLICY_SET_DEFINITION = "Microsoft.Authorization/policySetDefinitions";
    private const string API_VERSION_2023_04_01 = "2023-04-01";
    private const string API_VERSION_2022_07_01_PREVIEW = "2022-07-01-preview";


    private sealed class ResourceContext(IPolicyAssignmentExpandContext context, string tenantId)
    {
        private readonly IPolicyAssignmentExpandContext _Context = context;

        public string TenantId { get; } = tenantId;

        internal async Task<JObject> GetAsync(string resourceId, string apiVersion, string? queryString)
        {
            return await _Context.GetAsync(TenantId, resourceId, apiVersion, queryString);
        }

        internal async Task<JObject[]> ListAsync(string resourceId, string apiVersion, string? queryString, bool ignoreNotFound)
        {
            return await _Context.ListAsync(TenantId, resourceId, apiVersion, queryString, ignoreNotFound);
        }
    }

    public async Task VisitAsync(IPolicyAssignmentExpandContext context, JObject resource)
    {
        await ExpandResource(context, resource);
    }

    private async Task<bool> ExpandResource(IPolicyAssignmentExpandContext context, JObject resource)
    {
        if (resource == null ||
            !resource.TryStringProperty(PROPERTY_TYPE, out var resourceType) ||
            string.IsNullOrWhiteSpace(resourceType) ||
            !resource.TryStringProperty(PROPERTY_ID, out var resourceId))
            return false;

        var resourceContext = new ResourceContext(context, context.TenantId);

        return await VisitPolicyAssignment(resourceContext, resource, resourceType, resourceId);
    }

    /// <summary>
    /// Process a policy assignment.
    /// </summary>
    private static async Task<bool> VisitPolicyAssignment(ResourceContext resourceContext, JObject resource, string resourceType, string resourceId)
    {
        if (!string.Equals(resourceType, TYPE_POLICY_ASSIGNMENT, StringComparison.OrdinalIgnoreCase))
            return false;

        // Drop extra fields from the resource.
        resource.RemoveIfExists(PROPERTY_IDENTITY);
        resource.RemoveIfExists(PROPERTY_LOCATION);
        resource.RemoveIfExists(PROPERTY_SYSTEM_DATA);

        if (!resource.TryObjectProperty(PROPERTY_PROPERTIES, out var properties) || properties == null)
            return false;

        if (properties.TryObjectProperty(PROPERTY_METADATA, out var metadata) || metadata != null)
        {
            metadata.RemoveIfExists(PROPERTY_CREATED_BY);
            metadata.RemoveIfExists(PROPERTY_CREATED_BY_TYPE);
            metadata.RemoveIfExists(PROPERTY_CREATED_ON);
            metadata.RemoveIfExists(PROPERTY_UPDATED_BY);
            metadata.RemoveIfExists(PROPERTY_UPDATED_ON);
            metadata.RemoveIfExists(PROPERTY_LAST_MODIFIED_BY);
            metadata.RemoveIfExists(PROPERTY_LAST_MODIFIED_BY_TYPE);
            metadata.RemoveIfExists(PROPERTY_LAST_MODIFIED_AT);
        }

        // Get policy definition ID from properties.
        if (properties.TryStringProperty(PROPERTY_POLICY_DEFINITION_ID, out var policyDefinitionId) || !string.IsNullOrWhiteSpace(policyDefinitionId))
        {
            AddPolicyDefinitions(resource, await GetDefinitionOrDefinitionSet(resourceContext, policyDefinitionId));
        }

        if (properties.TryStringProperty(PROPERTY_SCOPE, out var scopeId) && !string.IsNullOrWhiteSpace(scopeId))
        {
            // Get policy assignment exemptions.
            AddExemptions(resource, await GetPolicyAssignmentExemptions(resourceContext, resourceId, scopeId));
        }

        return true;
    }

    private static async Task<JObject[]> GetPolicyAssignmentExemptions(ResourceContext context, string resourceId, string scopeId)
    {
        var queryString = $"$filter=policyAssignmentId eq '{resourceId}'";
        return await context.ListAsync(string.Concat(scopeId, "/providers/Microsoft.Authorization/policyExemptions"), API_VERSION_2022_07_01_PREVIEW, queryString, ignoreNotFound: true);
    }

    private static async Task<JObject[]> GetDefinitionOrDefinitionSet(ResourceContext context, string resourceId)
    {
        switch (GetPolicyDefinitionType(resourceId))
        {
            case PolicyDefinitionResourceType.PolicyDefinition:
                // Get a single policy definition.
                return [await GetResource(context, resourceId, API_VERSION_2023_04_01)];

            case PolicyDefinitionResourceType.PolicySetDefinition:
                // Get a single policy set definition.
                return await GetPolicyDefinitionSet(context, resourceId);

            default:
                // Unknown type, return empty.
                return [];
        }
    }

#nullable enable

    private static PolicyDefinitionResourceType GetPolicyDefinitionType(string resourceId)
    {
        if (!ResourceHelper.ResourceIdComponents(resourceId, out _, out _, out _, out _, out string[]? resourceType, out _) ||
            resourceType == null || resourceType.Length == 0)
            return PolicyDefinitionResourceType.Unknown;

        if (string.Equals(resourceType[0], TYPE_POLICY_DEFINITION, StringComparison.OrdinalIgnoreCase))
            return PolicyDefinitionResourceType.PolicyDefinition;

        if (string.Equals(resourceType[0], TYPE_POLICY_SET_DEFINITION, StringComparison.OrdinalIgnoreCase))
            return PolicyDefinitionResourceType.PolicySetDefinition;

        return PolicyDefinitionResourceType.Unknown;
    }

#nullable restore

    private static async Task<JObject[]> GetPolicyDefinitionSet(ResourceContext context, string resourceId)
    {
        var resource = await GetResource(context, resourceId, API_VERSION_2023_04_01);
        if (resource.TryObjectProperty(PROPERTY_PROPERTIES, out var properties) && properties != null &&
            properties.TryArrayProperty(PROPERTY_POLICY_DEFINITIONS, out var definitions) && definitions != null)
        {
            var result = new List<JObject>(definitions.Count);

            foreach (var definition in definitions.Values<JObject>())
            {
                if (definition.TryStringProperty(PROPERTY_POLICY_DEFINITION_ID, out var definitionId) && !string.IsNullOrWhiteSpace(definitionId))
                {
                    // Get the policy definition by ID.
                    var policyDefinition = await GetResource(context, definitionId, API_VERSION_2023_04_01);
                    if (policyDefinition != null)
                    {
                        result.Add(policyDefinition);
                    }
                }
            }

            return [.. result];
        }

        return [];
    }

    private static async Task<JObject> GetResource(ResourceContext context, string resourceId, string apiVersion)
    {
        return await context.GetAsync(resourceId, apiVersion, null);
    }

    private static void AddPolicyDefinitions(JObject parent, JObject[] definitions)
    {
        if (definitions == null || definitions.Length == 0)
            return;

        parent.UseProperty<JArray>(PROPERTY_POLICY_DEFINITIONS, out var resources);
        for (var i = 0; i < definitions.Length; i++)
            resources.Add(VisitPolicyDefinition(definitions[i]));
    }

    private static JObject VisitPolicyDefinition(JObject policyDefinition)
    {
        // Drop extra fields from the policy definition.
        policyDefinition.RemoveIfExists(PROPERTY_SYSTEM_DATA);

        if (!policyDefinition.TryObjectProperty(PROPERTY_PROPERTIES, out var properties) || properties == null)
            return policyDefinition;

        if (properties.TryObjectProperty(PROPERTY_METADATA, out var metadata) && metadata != null)
        {
            metadata.RemoveIfExists(PROPERTY_CREATED_BY);
            metadata.RemoveIfExists(PROPERTY_CREATED_BY_TYPE);
            metadata.RemoveIfExists(PROPERTY_CREATED_ON);
            metadata.RemoveIfExists(PROPERTY_UPDATED_BY);
            metadata.RemoveIfExists(PROPERTY_UPDATED_ON);
            metadata.RemoveIfExists(PROPERTY_LAST_MODIFIED_BY);
            metadata.RemoveIfExists(PROPERTY_LAST_MODIFIED_BY_TYPE);
            metadata.RemoveIfExists(PROPERTY_LAST_MODIFIED_AT);
        }

        return policyDefinition;
    }

    private static void AddExemptions(JObject parent, JObject[] exemptions)
    {
        if (exemptions == null || exemptions.Length == 0)
            return;

        parent.UseProperty<JArray>(PROPERTY_EXEMPTIONS, out var resources);
        for (var i = 0; i < exemptions.Length; i++)
            resources.Add(VisitExemption(exemptions[i]));
    }

    private static JObject VisitExemption(JObject exemption)
    {
        // Drop extra fields from the exemption.
        exemption.RemoveIfExists(PROPERTY_SYSTEM_DATA);

        return exemption;
    }
}

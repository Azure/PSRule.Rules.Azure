// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A template visitor for generating rule data.
    /// </summary>
    internal sealed class RuleDataExportVisitor : TemplateVisitor
    {
        private const string PROPERTY_DEPENDSON = "dependsOn";
        private const string PROPERTY_COMMENTS = "comments";
        private const string PROPERTY_APIVERSION = "apiVersion";
        private const string PROPERTY_CONDITION = "condition";
        private const string PROPERTY_RESOURCES = "resources";
        private const string PROPERTY_ID = "id";
        private const string PROPERTY_NAME = "name";
        private const string PROPERTY_PROPERTIES = "properties";
        private const string PROPERTY_CLIENTID = "clientId";
        private const string PROPERTY_PRINCIPALID = "principalId";
        private const string PROPERTY_TENANTID = "tenantId";
        private const string PROPERTY_ADMINISTRATORS = "administrators";
        private const string PROPERTY_IDENTITY = "identity";
        private const string PROPERTY_TYPE = "type";
        private const string PROPERTY_SITECONFIG = "siteConfig";
        private const string PROPERTY_SUBNETS = "subnets";
        private const string PROPERTY_NETWORKINTERFACES = "networkInterfaces";

        private const string PLACEHOLDER_GUID = "ffffffff-ffff-ffff-ffff-ffffffffffff";
        private const string IDENTITY_SYSTEMASSIGNED = "SystemAssigned";

        private const string TYPE_USERASSIGNEDIDENTITY = "Microsoft.ManagedIdentity/userAssignedIdentities";
        private const string TYPE_SQLSERVER = "Microsoft.Sql/servers";
        private const string TYPE_SQLSERVER_ADMINISTRATOR = "Microsoft.Sql/servers/administrators";
        private const string TYPE_WEBAPP = "Microsoft.Web/sites";
        private const string TYPE_WEBAPP_CONFIG = "Microsoft.Web/sites/config";
        private const string TYPE_WEBAPPSLOT = "Microsoft.Web/sites/slots";
        private const string TYPE_WEBAPPSLOT_CONFIG = "Microsoft.Web/sites/slots/config";
        private const string TYPE_VIRTUALNETWORK = "Microsoft.Network/virtualNetworks";
        private const string TYPE_PRIVATEENDPOINT = "Microsoft.Network/privateEndpoints";
        private const string TYPE_NETWORKINTERFACE = "Microsoft.Network/networkInterfaces";

        private static readonly JsonMergeSettings _MergeSettings = new()
        {
            MergeArrayHandling = MergeArrayHandling.Concat,
            MergeNullValueHandling = MergeNullValueHandling.Ignore,
            PropertyNameComparison = StringComparison.OrdinalIgnoreCase
        };

        protected override void Resource(TemplateContext context, IResourceValue resource)
        {
            // Remove resource properties that not required in rule data
            if (resource.Value.ContainsKey(PROPERTY_APIVERSION))
                resource.Value.Remove(PROPERTY_APIVERSION);

            if (resource.Value.ContainsKey(PROPERTY_CONDITION))
                resource.Value.Remove(PROPERTY_CONDITION);

            if (resource.Value.ContainsKey(PROPERTY_COMMENTS))
                resource.Value.Remove(PROPERTY_COMMENTS);

            if (!resource.Value.TryGetDependencies(out _))
                resource.Value.Remove(PROPERTY_DEPENDSON);

            base.Resource(context, resource);
        }

        protected override void EndTemplate(TemplateContext context, string deploymentName, JObject template)
        {
            var resources = context.GetResources();
            for (var i = 0; i < resources.Length; i++)
                MoveResource(context, resources[i]);

            BuildMaterializedView(context, context.GetResources());
            base.EndTemplate(context, deploymentName, template);
        }

        protected override void Emit(TemplateContext context, IResourceValue resource)
        {
            ProjectRuntimeProperties(context, resource);
            base.Emit(context, resource);
        }

        /// <summary>
        /// Build materialized views.
        /// </summary>
        private static void BuildMaterializedView(TemplateContext context, IResourceValue[] resources)
        {
            var remaining = new List<IResourceValue>(resources);
            var processed = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            for (var i = 0; resources != null && i < resources.Length; i++)
            {
                if (processed.Contains(resources[i].Id))
                    continue;

                MergeResource(context, resources[i], remaining, processed);
                ProjectEffectiveProperties(resources[i]);
                processed.Add(resources[i].Id);
                remaining.Remove(resources[i]);
            }
        }

        /// <summary>
        /// Project caulcauted properties into the resourcce.
        /// </summary>
        private static void ProjectEffectiveProperties(IResourceValue resource)
        {
            _ = ProjectWebApp(resource) ||
                ProjectSQLServer(resource);
        }

        /// <summary>
        /// Project runtime properties that are commonly referenced.
        /// </summary>
        private static void ProjectRuntimeProperties(TemplateContext context, IResourceValue resource)
        {
            _ = ProjectManagedIdentity(context, resource) ||
                ProjectVirtualNetwork(context, resource) ||
                ProjectPrivateEndpoints(context, resource) ||
                ProjectResource(context, resource);
        }

        private static bool ProjectResource(TemplateContext context, IResourceValue resource)
        {
            if (!resource.Value.TryGetProperty(PROPERTY_IDENTITY, out JObject identity) ||
                !identity.TryGetProperty(PROPERTY_TYPE, out var type) ||
                type.IndexOf(IDENTITY_SYSTEMASSIGNED, StringComparison.OrdinalIgnoreCase) == -1)
                return true;

            if (!identity.ContainsKeyInsensitive(PROPERTY_PRINCIPALID))
                identity.Add(PROPERTY_PRINCIPALID, PLACEHOLDER_GUID);

            if (!identity.ContainsKeyInsensitive(PROPERTY_TENANTID))
                identity.Add(PROPERTY_TENANTID, context.Tenant.TenantId);

            return true;
        }

        private static bool ProjectManagedIdentity(TemplateContext context, IResourceValue resource)
        {
            if (!resource.IsType(TYPE_USERASSIGNEDIDENTITY))
                return false;

            resource.Value.UseProperty(PROPERTY_PROPERTIES, out JObject properties);
            if (!properties.ContainsKeyInsensitive(PROPERTY_CLIENTID))
                properties.Add(PROPERTY_CLIENTID, PLACEHOLDER_GUID);

            if (!properties.ContainsKeyInsensitive(PROPERTY_PRINCIPALID))
                properties.Add(PROPERTY_PRINCIPALID, PLACEHOLDER_GUID);

            if (!properties.ContainsKeyInsensitive(PROPERTY_TENANTID))
                properties.Add(PROPERTY_TENANTID, context.Tenant.TenantId);

            return true;
        }

        private static bool ProjectVirtualNetwork(TemplateContext context, IResourceValue resource)
        {
            if (!resource.IsType(TYPE_VIRTUALNETWORK))
                return false;

            resource.Value.UseProperty(PROPERTY_PROPERTIES, out JObject properties);

            // Get subnets
            if (properties.TryArrayProperty(PROPERTY_SUBNETS, out var subnets))
            {
                foreach (var subnet in subnets.Values<JObject>())
                {
                    if (subnet.TryGetProperty(PROPERTY_NAME, out var name))
                        subnet[PROPERTY_ID] = string.Concat(resource.Id, "/subnets/", name);
                }
            }
            return true;
        }

        private static bool ProjectPrivateEndpoints(TemplateContext context, IResourceValue resource)
        {
            if (!resource.IsType(TYPE_PRIVATEENDPOINT))
                return false;

            if (!ResourceHelper.TryResourceGroup(resource.Id, out var subscriptionId, out var resourceGroupName))
                return true;

            resource.Value.UseProperty(PROPERTY_PROPERTIES, out JObject properties);

            // Add network interfaces
            if (!properties.ContainsKeyInsensitive(PROPERTY_NETWORKINTERFACES))
            {
                var networkInterface = new JObject
                {
                    [PROPERTY_ID] = ResourceHelper.CombineResourceId(subscriptionId, resourceGroupName, TYPE_NETWORKINTERFACE, $"pe.nic.{ExpressionHelpers.GetUniqueString(new object[] { resource.Id })}")
                };
                properties[PROPERTY_NETWORKINTERFACES] = new JArray(new JObject[] { networkInterface });
            }
            return true;
        }

        private static bool ProjectSQLServer(IResourceValue resource)
        {
            if (!resource.IsType(TYPE_SQLSERVER))
                return false;

            if (!resource.Value.TryGetResources(TYPE_SQLSERVER_ADMINISTRATOR, out var subResources))
                return true;

            for (var i = 0; i < subResources.Length; i++)
            {
                if (subResources[i].ResourceNameEquals("ActiveDirectory") &&
                    subResources[i].TryGetProperty<JObject>(PROPERTY_PROPERTIES, out var overrideProperties))
                {
                    resource.Value.UseProperty<JObject>(PROPERTY_PROPERTIES, out var properties);
                    properties.UseProperty<JObject>(PROPERTY_ADMINISTRATORS, out var administrators);
                    administrators.Merge(overrideProperties, _MergeSettings);
                }
            }
            return true;
        }

        private static bool ProjectWebApp(IResourceValue resource)
        {
            string configType = null;
            if (resource.IsType(TYPE_WEBAPP))
                configType = TYPE_WEBAPP_CONFIG;
            else if (resource.IsType(TYPE_WEBAPPSLOT))
                configType = TYPE_WEBAPPSLOT_CONFIG;

            if (configType == null)
                return false;

            if (!resource.Value.TryGetResources(configType, out var subResources))
                return true;

            for (var i = 0; i < subResources.Length; i++)
            {
                if (subResources[i].ResourceNameEquals("web") &&
                    subResources[i].TryGetProperty<JObject>(PROPERTY_PROPERTIES, out var overrideProperties))
                {
                    resource.Value.UseProperty<JObject>(PROPERTY_PROPERTIES, out var properties);
                    properties.UseProperty<JObject>(PROPERTY_SITECONFIG, out var siteConfig);
                    siteConfig.Merge(overrideProperties, _MergeSettings);
                }
            }
            return true;
        }

        /// <summary>
        /// Merge resources based on duplicates which could occur across modules.
        /// </summary>
        private static void MergeResource(TemplateContext context, IResourceValue resource, List<IResourceValue> unprocessed, HashSet<string> processed)
        {
            if (!ShouldMerge(resource.Type))
                return;

            var duplicates = unprocessed.FindAll(x => x.Id == resource.Id);
            for (var i = 1; duplicates.Count > 1 && i < duplicates.Count; i++)
            {
                MergeResource(duplicates[0].Value, duplicates[i].Value, processed);
                unprocessed.Remove(duplicates[i]);
                context.RemoveResource(duplicates[i]);
            }
        }

        /// <summary>
        /// Merge specific resources and thier sub-resources.
        /// </summary>
        private static void MergeResource(JObject resourceA, JObject resourceB, HashSet<string> processed)
        {
            resourceA.Merge(resourceB, _MergeSettings);

            // Handle child resources
            if (resourceA.TryGetResources(out var resources))
            {
                for (var i = 0; resources != null && i < resources.Length; i++)
                {
                    if (!resources[i].TryGetProperty(PROPERTY_ID, out var childResourceId) || processed.Contains(childResourceId))
                        continue;

                    var duplicates = Array.FindAll(resources, x => x[PROPERTY_ID].ToString() == childResourceId);
                    for (var j = 1; duplicates.Length > 1 && j < duplicates.Length; j++)
                    {
                        MergeResource(duplicates[0].Value<JObject>(), duplicates[j].Value<JObject>(), processed);
                        duplicates[j].Remove();
                    }
                    processed.Add(childResourceId);
                }
            }
        }

        /// <summary>
        /// Move sub-resources based on parent resource relationship.
        /// This process nests sub-resources so that relationship can be analyzed.
        /// </summary>
        private static void MoveResource(TemplateContext context, IResourceValue resource)
        {
            if (!ShouldMove(resource.Type))
                return;

            if (resource.Value.TryGetDependencies(out _) || resource.Type.Split('/').Length > 2)
            {
                resource.Value.Remove(PROPERTY_DEPENDSON);
                if (context.TryParentResourceId(resource.Value, out var parentResourceId))
                {
                    for (var j = 0; j < parentResourceId.Length; j++)
                    {
                        if (context.TryGetResource(parentResourceId[j], out var parent))
                        {
                            parent.Value.UseProperty(PROPERTY_RESOURCES, out JArray innerResources);
                            innerResources.Add(resource.Value);
                            context.RemoveResource(resource);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Determines if the specific sub-resource type should be nested.
        /// </summary>
        private static bool ShouldMove(string resourceType)
        {
            return !string.Equals(resourceType, "Microsoft.Sql/servers/databases", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Determines if the specific resource type should be merged.
        /// </summary>
        private static bool ShouldMerge(string resourceType)
        {
            return string.Equals(resourceType, "Microsoft.Storage/storageAccounts", StringComparison.OrdinalIgnoreCase);
        }
    }
}

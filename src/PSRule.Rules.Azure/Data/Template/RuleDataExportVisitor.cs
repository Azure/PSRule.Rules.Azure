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
        private const string PROPERTY_PROPERTIES = "properties";

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
                ProjectProperties(resources[i]);
                processed.Add(resources[i].Id);
                remaining.Remove(resources[i]);
            }
        }

        /// <summary>
        /// Project caulcauted properties into the resourcce.
        /// </summary>
        private static void ProjectProperties(IResourceValue resource)
        {
            _ = ProjectWebApp(resource) ||
                ProjectSQLServer(resource);
        }

        private static bool ProjectSQLServer(IResourceValue resource)
        {
            if (!resource.IsType("Microsoft.Sql/servers"))
                return false;

            if (!resource.Value.TryGetResources("Microsoft.Sql/servers/administrators", out var subResources))
                return true;

            for (var i = 0; i < subResources.Length; i++)
            {
                if (subResources[i].ResourceNameEquals("ActiveDirectory") && subResources[i].TryGetProperty<JObject>(PROPERTY_PROPERTIES, out var overrideProperties))
                {
                    resource.Value.UseProperty<JObject>(PROPERTY_PROPERTIES, out var properties);
                    properties.UseProperty<JObject>("administrators", out var administrators);
                    administrators.Merge(overrideProperties, _MergeSettings);
                }
            }
            return true;
        }

        private static bool ProjectWebApp(IResourceValue resource)
        {
            string configType = null;
            if (resource.IsType("Microsoft.Web/sites"))
                configType = "Microsoft.Web/sites/config";
            else if (resource.IsType("Microsoft.Web/sites/slots"))
                configType = "Microsoft.Web/sites/slots/config";

            if (configType == null)
                return false;

            if (!resource.Value.TryGetResources(configType, out var subResources))
                return true;

            for (var i = 0; i < subResources.Length; i++)
            {
                if (subResources[i].ResourceNameEquals("web") && subResources[i].TryGetProperty<JObject>(PROPERTY_PROPERTIES, out var overrideProperties))
                {
                    resource.Value.UseProperty<JObject>(PROPERTY_PROPERTIES, out var properties);
                    properties.UseProperty<JObject>("siteConfig", out var siteConfig);
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

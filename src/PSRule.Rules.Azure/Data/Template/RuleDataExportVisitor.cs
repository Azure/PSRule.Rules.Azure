// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
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

            // Move sub-resources based on parent resource relationship
            for (var i = 0; i < resources.Length; i++)
                MoveResource(context, resources[i]);

            base.EndTemplate(context, deploymentName, template);
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
    }
}

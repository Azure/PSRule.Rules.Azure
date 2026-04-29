// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Terraform;

/// <summary>
/// A helper for processing Terraform plan JSON files and extracting Azure resources.
/// </summary>
internal sealed class TerraformPlanHelper
{
    private const string AZAPI_PROVIDER = "azure/azapi";
    private const string FORMAT_VERSION_PREFIX = "1.";
    private const string MODE_MANAGED = "managed";

    /// <summary>
    /// Process a Terraform plan JSON file and extract Azure resources as PSObjects.
    /// </summary>
    internal PSObject[] ProcessPlanFile(string planFile)
    {
        if (!File.Exists(planFile))
            throw new FileNotFoundException(string.Format("The Terraform plan file '{0}' was not found.", planFile), planFile);

        var plan = ReadJsonFile(planFile);

        // Validate the plan format.
        var formatVersion = plan["format_version"]?.Value<string>();
        if (formatVersion == null || !formatVersion.StartsWith(FORMAT_VERSION_PREFIX, StringComparison.Ordinal))
            throw new TerraformPlanException(string.Format("Unsupported Terraform plan format version '{0}'. Expected version starting with '1.'.", formatVersion));

        // Extract resources from planned_values.
        var plannedValues = plan["planned_values"] as JObject;
        if (plannedValues == null)
            return [];

        var rootModule = plannedValues["root_module"] as JObject;
        if (rootModule == null)
            return [];

        // Walk the module tree and collect ARM-format resources.
        var armResources = new List<JObject>();
        CollectResources(rootModule, armResources);

        if (armResources.Count == 0)
            return [];

        // Convert to PSObject[] using the same pattern as template expansion.
        return ConvertToPSObjects(armResources);
    }

    /// <summary>
    /// Recursively collect Azure resources from a module and its child modules.
    /// </summary>
    private static void CollectResources(JObject module, List<JObject> results)
    {
        // Process resources in this module.
        var resources = module["resources"] as JArray;
        if (resources != null)
        {
            foreach (var resource in resources)
            {
                if (resource is not JObject resourceObj)
                    continue;

                var converted = ConvertResource(resourceObj);
                if (converted != null)
                    results.Add(converted);
            }
        }

        // Recurse into child modules.
        var childModules = module["child_modules"] as JArray;
        if (childModules != null)
        {
            foreach (var child in childModules)
            {
                if (child is JObject childObj)
                    CollectResources(childObj, results);
            }
        }
    }

    /// <summary>
    /// Convert a single Terraform plan resource to ARM format based on provider type.
    /// </summary>
    private static JObject ConvertResource(JObject planResource)
    {
        // Skip data sources — they are read-only lookups.
        var mode = planResource["mode"]?.Value<string>();
        if (!string.Equals(mode, MODE_MANAGED, StringComparison.OrdinalIgnoreCase))
            return null;

        // Determine provider.
        var providerName = planResource["provider_name"]?.Value<string>();
        if (string.IsNullOrEmpty(providerName))
            return null;

        // Check if this is an azapi provider resource.
        if (providerName.IndexOf(AZAPI_PROVIDER, StringComparison.OrdinalIgnoreCase) >= 0)
        {
            var terraformType = planResource["type"]?.Value<string>();
            if (!AzApiResourceConverter.IsSupportedType(terraformType))
                return null;

            return AzApiResourceConverter.Convert(planResource);
        }

        // Other providers (azurerm, etc.) are not yet supported.
        return null;
    }

    /// <summary>
    /// Convert ARM-format JObjects to PSObject array.
    /// </summary>
    private static PSObject[] ConvertToPSObjects(List<JObject> armResources)
    {
        var results = new List<PSObject>(armResources.Count);
        var serializer = new JsonSerializer();
        serializer.Converters.Add(new PSObjectJsonConverter());

        foreach (var resource in armResources)
            results.Add(resource.ToObject<PSObject>(serializer));

        return [.. results];
    }

    /// <summary>
    /// Read and parse a JSON file.
    /// </summary>
    private static JObject ReadJsonFile(string path)
    {
        using var stream = new StreamReader(path);
        using var reader = new JsonTextReader(stream);
        return JObject.Load(reader);
    }

    /// <summary>
    /// Check if a JObject represents a Terraform plan file.
    /// </summary>
    internal static bool IsTerraformPlan(JObject content)
    {
        var formatVersion = content?["format_version"]?.Value<string>();
        return formatVersion != null
            && formatVersion.StartsWith(FORMAT_VERSION_PREFIX, StringComparison.Ordinal)
            && content["planned_values"] != null;
    }
}

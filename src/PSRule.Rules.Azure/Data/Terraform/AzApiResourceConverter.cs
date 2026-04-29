// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Terraform;

/// <summary>
/// Converts azapi_resource entries from Terraform plan JSON to ARM-format JObjects.
/// </summary>
internal static class AzApiResourceConverter
{
    private const string AZAPI_RESOURCE = "azapi_resource";
    private const string AZAPI_UPDATE_RESOURCE = "azapi_update_resource";
    private const string SENSITIVE_VALUE = "(sensitive value)";

    /// <summary>
    /// Determines if the Terraform resource type is a supported azapi resource type.
    /// </summary>
    internal static bool IsSupportedType(string terraformType)
    {
        return string.Equals(terraformType, AZAPI_RESOURCE, StringComparison.OrdinalIgnoreCase) ||
               string.Equals(terraformType, AZAPI_UPDATE_RESOURCE, StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Convert a single azapi_resource from plan JSON values to ARM format.
    /// </summary>
    internal static JObject Convert(JObject planResource)
    {
        if (planResource == null)
            return null;

        var values = planResource["values"] as JObject;
        if (values == null)
            return null;

        // Parse type and apiVersion from "Microsoft.X/Y@2023-01-01".
        var typeValue = values["type"]?.Value<string>();
        if (string.IsNullOrEmpty(typeValue))
            return null;

        ParseType(typeValue, out var resourceType, out var apiVersion);

        // Get name - skip resource if null.
        var name = values["name"]?.Value<string>();
        if (string.IsNullOrEmpty(name))
            return null;

        // Get location.
        var location = GetNonSensitiveString(values, "location");

        // Construct resource ID from parent_id + type + name.
        var parentId = values["parent_id"]?.Value<string>();
        var resourceId = BuildResourceId(parentId, resourceType, name);

        // Build ARM-format JObject.
        var result = new JObject
        {
            ["id"] = resourceId,
            ["type"] = resourceType,
            ["name"] = name,
        };

        if (!string.IsNullOrEmpty(apiVersion))
            result["apiVersion"] = apiVersion;

        if (location != null)
            result["location"] = location;

        // Parse and merge body (may be string JSON or object).
        var body = ParseBody(values["body"]);
        if (body != null)
        {
            foreach (var prop in body.Properties())
            {
                // Body properties merge into the resource root.
                // Skip tags from body - top-level tags take precedence.
                if (!string.Equals(prop.Name, "tags", StringComparison.OrdinalIgnoreCase))
                    result[prop.Name] = prop.Value.DeepClone();
            }
        }

        // Tags: top-level takes precedence, then body.tags.
        var tags = GetNonSensitiveToken(values, "tags") as JObject;
        if (tags == null && body != null)
            tags = body["tags"] as JObject;

        if (tags != null)
            result["tags"] = tags.DeepClone();

        // Convert identity block from Terraform format to ARM format.
        ConvertIdentity(values, result);

        return result;
    }

    /// <summary>
    /// Parse the azapi type string into resource type and API version.
    /// </summary>
    private static void ParseType(string typeValue, out string resourceType, out string apiVersion)
    {
        var atIndex = typeValue.IndexOf('@');
        if (atIndex > 0)
        {
            resourceType = typeValue.Substring(0, atIndex);
            apiVersion = typeValue.Substring(atIndex + 1);
        }
        else
        {
            resourceType = typeValue;
            apiVersion = null;
        }
    }

    /// <summary>
    /// Build the ARM resource ID from parent_id, resource type, and name.
    /// </summary>
    private static string BuildResourceId(string parentId, string resourceType, string name)
    {
        if (string.IsNullOrEmpty(resourceType) || string.IsNullOrEmpty(name))
            return null;

        // For child resources the type has multiple segments e.g. "Microsoft.Network/virtualNetworks/subnets".
        // The parent_id already contains the parent resource path.
        var typeSegments = resourceType.Split('/');

        if (typeSegments.Length >= 2)
        {
            // Top-level resource: parent_id is resource group or subscription scope.
            // E.g. type = "Microsoft.Storage/storageAccounts", parentId = "/subscriptions/.../resourceGroups/..."
            if (typeSegments.Length == 2)
            {
                return string.IsNullOrEmpty(parentId)
                    ? string.Concat("/providers/", resourceType, "/", name)
                    : string.Concat(parentId, "/providers/", resourceType, "/", name);
            }

            // Child resource: parent_id contains parent resource, type is multi-segment.
            // E.g. type = "Microsoft.Network/virtualNetworks/subnets", parentId = ".../virtualNetworks/myvnet"
            // We only need the last segment of the type.
            var lastSegment = typeSegments[typeSegments.Length - 1];
            return string.IsNullOrEmpty(parentId)
                ? string.Concat("/", lastSegment, "/", name)
                : string.Concat(parentId, "/", lastSegment, "/", name);
        }

        return string.IsNullOrEmpty(parentId)
            ? string.Concat("/providers/", resourceType, "/", name)
            : string.Concat(parentId, "/providers/", resourceType, "/", name);
    }

    /// <summary>
    /// Parse the body value which may be a JSON string or a JObject.
    /// </summary>
    private static JObject ParseBody(JToken body)
    {
        if (body == null || body.Type == JTokenType.Null)
            return null;

        if (body.Type == JTokenType.String)
        {
            var bodyString = body.Value<string>();
            if (string.IsNullOrEmpty(bodyString) || bodyString == SENSITIVE_VALUE)
                return null;

            return JObject.Parse(bodyString);
        }

        return body as JObject;
    }

    /// <summary>
    /// Convert the identity block from Terraform format to ARM format.
    /// </summary>
    private static void ConvertIdentity(JObject values, JObject result)
    {
        var identity = values["identity"] as JObject;
        if (identity == null || identity.Type == JTokenType.Null)
            return;

        var identityType = identity["type"]?.Value<string>();
        if (string.IsNullOrEmpty(identityType))
            return;

        var armIdentity = new JObject
        {
            ["type"] = identityType
        };

        // Convert identity_ids array to userAssignedIdentities object.
        var identityIds = identity["identity_ids"] as JArray;
        if (identityIds != null && identityIds.Count > 0)
        {
            var userAssigned = new JObject();
            foreach (var id in identityIds)
            {
                var idStr = id.Value<string>();
                if (!string.IsNullOrEmpty(idStr))
                    userAssigned[idStr] = new JObject();
            }

            if (userAssigned.Count > 0)
                armIdentity["userAssignedIdentities"] = userAssigned;
        }

        result["identity"] = armIdentity;
    }

    /// <summary>
    /// Get a string value from a JObject, returning null if the value is a sensitive placeholder.
    /// </summary>
    private static string GetNonSensitiveString(JObject obj, string propertyName)
    {
        var token = obj[propertyName];
        if (token == null || token.Type == JTokenType.Null)
            return null;

        var value = token.Value<string>();
        return value == SENSITIVE_VALUE ? null : value;
    }

    /// <summary>
    /// Get a token from a JObject, returning null if the value is a sensitive placeholder.
    /// </summary>
    private static JToken GetNonSensitiveToken(JObject obj, string propertyName)
    {
        var token = obj[propertyName];
        if (token == null || token.Type == JTokenType.Null)
            return null;

        if (token.Type == JTokenType.String && token.Value<string>() == SENSITIVE_VALUE)
            return null;

        return token;
    }
}

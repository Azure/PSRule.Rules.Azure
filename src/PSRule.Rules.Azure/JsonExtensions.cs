// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure;

internal static class JsonExtensions
{
    private const string PROPERTY_DEPENDS_ON = "dependsOn";
    private const string PROPERTY_RESOURCES = "resources";
    private const string PROPERTY_NAME = "name";
    private const string PROPERTY_TYPE = "type";
    private const string PROPERTY_ITEMS = "items";
    private const string PROPERTY_VALUE = "value";
    private const string PROPERTY_FIELD = "field";
    private const string PROPERTY_EXISTING = "existing";
    private const string PROPERTY_IMPORT = "import";
    private const string PROPERTY_SCOPE = "scope";
    private const string PROPERTY_SUBSCRIPTION_ID = "subscriptionId";
    private const string PROPERTY_RESOURCE_GROUP = "resourceGroup";

    private const string TARGETINFO_KEY = "_PSRule";
    private const string TARGETINFO_SOURCE = "source";
    private const string TARGETINFO_FILE = "file";
    private const string TARGETINFO_LINE = "line";
    private const string TARGETINFO_POSITION = "position";
    private const string TARGETINFO_TYPE = "type";
    private const string TARGETINFO_TYPE_TEMPLATE = "Template";
    private const string TARGETINFO_TYPE_PARAMETER = "Parameter";
    private const string TARGETINFO_ISSUE = "issue";
    private const string TARGETINFO_NAME = "name";
    private const string TARGETINFO_PATH = "path";
    private const string TARGETINFO_MESSAGE = "message";

    private const string TENANT_SCOPE = "/";

    private static readonly string[] JSON_PATH_SEPARATOR = ["."];

    internal static IJsonLineInfo TryLineInfo(this JToken token)
    {
        if (token == null)
            return null;

        var annotation = token.Annotation<TemplateTokenAnnotation>();
        return annotation ?? (IJsonLineInfo)token;
    }

    internal static JToken CloneTemplateJToken(this JToken token)
    {
        if (token == null)
            return null;

        var annotation = token.UseTokenAnnotation();
        var clone = token.DeepClone();
        if (annotation != null)
            clone.AddAnnotation(annotation);

        return clone;
    }

    internal static void CopyTemplateAnnotationFrom(this JToken token, JToken source)
    {
        if (token == null || source == null)
            return;

        var annotation = source.Annotation<TemplateTokenAnnotation>();
        if (annotation != null)
            token.AddAnnotation(annotation);
    }

    internal static bool TryGetResources(this JObject resource, out JObject[] resources)
    {
        if (!resource.TryGetProperty<JArray>(PROPERTY_RESOURCES, out var jArray) || jArray.Count == 0)
        {
            resources = null;
            return false;
        }
        resources = jArray.Values<JObject>().ToArray();
        return true;
    }

    internal static bool TryGetResources(this JObject resource, string type, out JObject[] resources)
    {
        if (!resource.TryGetProperty<JArray>(PROPERTY_RESOURCES, out var jArray) || jArray.Count == 0)
        {
            resources = null;
            return false;
        }
        var results = new List<JObject>();
        foreach (var item in jArray.Values<JObject>())
            if (item.PropertyEquals(PROPERTY_TYPE, type))
                results.Add(item);

        resources = results.Count > 0 ? results.ToArray() : null;
        return results.Count > 0;
    }

    internal static bool TryGetResourcesArray(this JObject resource, out JArray resources)
    {
        if (resource.TryGetProperty(PROPERTY_RESOURCES, out resources))
            return true;

        return false;
    }

    internal static bool PropertyEquals(this JObject o, string propertyName, string value)
    {
        return o.TryGetProperty(propertyName, out var s) && string.Equals(s, value, StringComparison.OrdinalIgnoreCase);
    }

    internal static bool ResourceNameEquals(this JObject o, string name)
    {
        if (!o.TryGetProperty(PROPERTY_NAME, out var n))
            return false;

        n = n.SplitLastSegment('/');
        return string.Equals(n, name, StringComparison.OrdinalIgnoreCase);
    }

    internal static bool ContainsKeyInsensitive(this JObject o, string propertyName)
    {
        return o.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out _);
    }

    /// <summary>
    /// Determine if the token is a value.
    /// </summary>
    internal static bool HasValue(this JToken o)
    {
        return o.Type is JTokenType.String or
            JTokenType.Integer or
            JTokenType.Object or
            JTokenType.Array or
            JTokenType.Boolean or
            JTokenType.Bytes or
            JTokenType.Date or
            JTokenType.Float or
            JTokenType.Guid or
            JTokenType.TimeSpan or
            JTokenType.Uri;
    }

    /// <summary>
    /// Add items to the array.
    /// </summary>
    /// <param name="o">The <seealso cref="JArray"/> to add items to.</param>
    /// <param name="items">A set of items to add.</param>
    internal static void AddRange(this JArray o, IEnumerable<JToken> items)
    {
        foreach (var item in items)
            o.Add(item);
    }

    /// <summary>
    /// Add items to the start of the array instead of the end.
    /// </summary>
    /// <param name="o">The <seealso cref="JArray"/> to add items to.</param>
    /// <param name="items">A set of items to add.</param>
    internal static void AddRangeFromStart(this JArray o, IEnumerable<JToken> items)
    {
        var counter = 0;
        foreach (var item in items)
            o.Insert(counter++, item);
    }

    internal static IEnumerable<JObject> GetPeerConditionByField(this JObject o, string field)
    {
        return o.BeforeSelf().OfType<JObject>().Where(peer => peer.TryGetProperty(PROPERTY_FIELD, out var peerField) &&
            string.Equals(field, peerField, StringComparison.OrdinalIgnoreCase));
    }

    internal static bool TryGetProperty<TValue>(this JObject o, string propertyName, out TValue value) where TValue : JToken
    {
        value = null;
        if (o.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var v) && v.Type != JTokenType.Null)
        {
            value = v.Value<TValue>();
            return value != null;
        }
        return false;
    }

    internal static bool TryGetProperty(this JObject o, string propertyName, out string value)
    {
        value = null;
        if (!TryGetProperty<JValue>(o, propertyName, out var v))
            return false;

        value = v.Value<string>();
        return true;
    }

    internal static bool TryGetProperty(this JProperty property, string propertyName, out string value)
    {
        value = null;
        if (property == null || property.Value.Type != JTokenType.String || !property.Name.Equals(propertyName, StringComparison.OrdinalIgnoreCase))
            return false;

        value = property.Value.Value<string>();
        return true;
    }

    internal static bool TryRenameProperty(this JObject o, string oldName, string newName)
    {
        var p = o.Property(oldName, StringComparison.OrdinalIgnoreCase);
        if (p != null)
        {
            p.Replace(new JProperty(newName, p.Value));
            return true;
        }
        return false;
    }

    internal static void ReplaceProperty<TValue>(this JObject o, string propertyName, TValue value) where TValue : JToken
    {
        var p = o.Property(propertyName, StringComparison.OrdinalIgnoreCase);
        if (p != null)
            p.Value = value;
    }

    internal static void ReplaceProperty(this JObject o, string propertyName, string value)
    {
        var p = o.Property(propertyName, StringComparison.OrdinalIgnoreCase);
        if (p != null)
            p.Value = JValue.CreateString(value);
    }

    internal static void ReplaceProperty(this JObject o, string propertyName, bool value)
    {
        var p = o.Property(propertyName, StringComparison.OrdinalIgnoreCase);
        if (p != null)
            p.Value = new JValue(value);
    }

    internal static void ReplaceProperty(this JObject o, string propertyName, int value)
    {
        var p = o.Property(propertyName, StringComparison.OrdinalIgnoreCase);
        if (p != null)
            p.Value = new JValue(value);
    }

    internal static void RemoveProperty(this JObject o, string propertyName)
    {
        var p = o.Property(propertyName, StringComparison.OrdinalIgnoreCase);
        p?.Remove();
    }

    /// <summary>
    /// Convert a string property to an integer.
    /// </summary>
    /// <param name="o">The target object with properties.</param>
    /// <param name="propertyName">The name of the property to convert.</param>
    internal static void ConvertPropertyToInt(this JObject o, string propertyName)
    {
        if (o.TryStringProperty(propertyName, out var s) && int.TryParse(s, out var value))
            o.ReplaceProperty(propertyName, value);
    }

    /// <summary>
    /// Convert a string property to a boolean.
    /// </summary>
    /// <param name="o">The target object with properties.</param>
    /// <param name="propertyName">The name of the property to convert.</param>
    internal static void ConvertPropertyToBool(this JObject o, string propertyName)
    {
        if (o.TryStringProperty(propertyName, out var s) && bool.TryParse(s, out var value))
            o.ReplaceProperty(propertyName, value);
    }

    internal static bool TryRenameProperty(this JProperty property, string oldName, string newName)
    {
        if (property == null || !property.Name.Equals(oldName, StringComparison.OrdinalIgnoreCase))
            return false;

        property.Parent[newName] = property.Value;
        property.Remove();
        return true;
    }

    internal static bool TryRenameProperty(this JProperty property, string newName)
    {
        if (property == null || property.Name == newName)
            return false;

        property.Parent[newName] = property.Value;
        property.Remove();
        return true;
    }

    internal static void UseProperty<TValue>(this JObject o, string propertyName, out TValue value) where TValue : JToken, new()
    {
        if (!o.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var v))
        {
            value = new TValue();
            o.Add(propertyName, value);
            return;
        }
        value = (TValue)v;
    }

    internal static void UseTokenAnnotation(this JToken[] token, string parentPath = null, string propertyPath = null)
    {
        for (var i = 0; token != null && i < token.Length; i++)
            token[i].UseTokenAnnotation(parentPath, string.Concat(propertyPath, '[', i, ']'));
    }

    internal static TemplateTokenAnnotation UseTokenAnnotation(this JToken token, string parentPath = null, string propertyPath = null)
    {
        var annotation = token.Annotation<TemplateTokenAnnotation>();
        if (annotation != null)
            return annotation;

        if (token is IJsonLineInfo lineInfo && lineInfo.HasLineInfo())
            annotation = new TemplateTokenAnnotation(lineInfo.LineNumber, lineInfo.LinePosition, JsonPathJoin(parentPath, propertyPath ?? token.Path));
        else
            annotation = new TemplateTokenAnnotation(0, 0, JsonPathJoin(parentPath, propertyPath ?? token.Path));

        token.AddAnnotation(annotation);
        return annotation;
    }

    private static string JsonPathJoin(string parent, string child)
    {
        if (string.IsNullOrEmpty(parent))
            return child;

        return string.IsNullOrEmpty(child) ? parent : string.Concat(parent, ".", child);
    }

    /// <summary>
    /// Get the dependencies for a resource by extracting any identifiers configured on the <c>dependsOn</c> property.
    /// </summary>
    /// <param name="resource">The resource object to check.</param>
    /// <param name="dependencies">An array of dependencies if set.</param>
    /// <returns></returns>
    internal static bool TryGetDependencies(this JObject resource, out string[] dependencies)
    {
        dependencies = null;
        if (!(resource.ContainsKey(PROPERTY_DEPENDS_ON) && resource[PROPERTY_DEPENDS_ON] is JArray d && d.Count > 0))
            return false;

        dependencies = d.Values<string>().ToArray();
        return true;
    }

    internal static string GetResourcePath(this JObject resource, int parentLevel = 0)
    {
        var annotation = resource.Annotation<TemplateTokenAnnotation>();
        var path = annotation?.Path ?? resource.Path;
        if (parentLevel == 0 || string.IsNullOrEmpty(path))
            return path;

        var parts = path.Split(JSON_PATH_SEPARATOR, StringSplitOptions.None);
        return parts.Length > parentLevel ? string.Join(JSON_PATH_SEPARATOR[0], parts, 0, parts.Length - parentLevel) : string.Empty;
    }

    internal static void SetTargetInfo(this JObject resource, string templateFile, string parameterFile, string path = null)
    {
        // Get line information.
        var lineInfo = resource.TryLineInfo();

        // Populate target info.
        resource.UseProperty(TARGETINFO_KEY, out JObject targetInfo);

        // Path.
        path ??= resource.GetResourcePath();
        targetInfo.Add(TARGETINFO_PATH, path);

        var sources = new JArray();

        // Template file.
        if (!string.IsNullOrEmpty(templateFile))
        {
            var source = new JObject
            {
                [TARGETINFO_FILE] = templateFile,
                [TARGETINFO_TYPE] = TARGETINFO_TYPE_TEMPLATE
            };
            if (lineInfo.HasLineInfo())
            {
                source[TARGETINFO_LINE] = lineInfo.LineNumber;
                source[TARGETINFO_POSITION] = lineInfo.LinePosition;
            }
            sources.Add(source);
        }

        // Parameter file.
        if (!string.IsNullOrEmpty(parameterFile))
        {
            var source = new JObject
            {
                [TARGETINFO_FILE] = parameterFile,
                [TARGETINFO_TYPE] = TARGETINFO_TYPE_PARAMETER
            };
            if (lineInfo.HasLineInfo())
            {
                source[TARGETINFO_LINE] = 1;
            }
            sources.Add(source);
        }
        targetInfo.Add(TARGETINFO_SOURCE, sources);
    }

    internal static void SetValidationIssue(this JObject resource, string issueId, string name, string path, string message, params object[] args)
    {
        // Populate target info
        resource.UseProperty(TARGETINFO_KEY, out JObject targetInfo);

        var issues = targetInfo.ContainsKey(TARGETINFO_ISSUE) ? targetInfo.Value<JArray>(TARGETINFO_ISSUE) : new JArray();

        // Format message
        message = args.Length > 0 ? string.Format(Thread.CurrentThread.CurrentCulture, message, args) : message;

        // Build issue
        var issue = new JObject
        {
            [TARGETINFO_TYPE] = issueId,
            [TARGETINFO_NAME] = name,
            [TARGETINFO_PATH] = path,
            [TARGETINFO_MESSAGE] = message,
        };
        issues.Add(issue);
        targetInfo[TARGETINFO_ISSUE] = issues;
    }

    internal static bool TryArrayProperty(this JObject obj, string propertyName, out JArray propertyValue)
    {
        propertyValue = null;
        if (!obj.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var value) || value.Type != JTokenType.Array)
            return false;

        propertyValue = value.Value<JArray>();
        return true;
    }

    internal static bool TryObjectProperty(this JObject obj, string propertyName, out JObject propertyValue)
    {
        propertyValue = null;
        if (!obj.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var value) || value.Type != JTokenType.Object)
            return false;

        propertyValue = value as JObject;
        return true;
    }

    internal static bool TryStringProperty(this JObject obj, string propertyName, out string propertyValue)
    {
        propertyValue = null;
        if (!obj.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var value) || value.Type != JTokenType.String)
            return false;

        propertyValue = value.Value<string>();
        return true;
    }

    internal static bool TryBoolProperty(this JObject o, string propertyName, out bool? value)
    {
        value = null;
        if (o.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var token) && token.Type == JTokenType.Boolean)
        {
            value = token.Value<bool>();
            return value != null;
        }
        else if (token != null && token.Type == JTokenType.String && bool.TryParse(token.Value<string>(), out var v))
        {
            value = v;
            return true;
        }
        return false;
    }

    internal static bool TryIntegerProperty(this JObject o, string propertyName, out long? value)
    {
        value = null;
        if (o.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var token) && token.Type == JTokenType.Integer)
        {
            value = token.Value<long>();
            return value != null;
        }
        else if (token != null && token.Type == JTokenType.String && long.TryParse(token.Value<string>(), out var v))
        {
            value = v;
            return true;
        }
        return false;
    }

    /// <summary>
    /// Check if the script uses an expression.
    /// </summary>
    internal static bool IsExpressionString(this JToken token)
    {
        if (token == null || token.Type != JTokenType.String)
            return false;

        var value = token.Value<string>();
        return value != null && value.IsExpressionString();
    }

    internal static bool IsEmpty(this JToken value)
    {
        return value.Type == JTokenType.None ||
            value.Type == JTokenType.Null ||
            (value.Type == JTokenType.String && string.IsNullOrEmpty(value.Value<string>()));
    }

    /// <summary>
    /// Resources with the <c>existing</c> property set to <c>true</c> are references to existing resources.
    /// </summary>
    /// <param name="o">The resource <seealso cref="JObject"/>.</param>
    /// <returns>Returns <c>true</c> if the resource is a reference to an existing resource.</returns>
    internal static bool IsExisting(this JObject o)
    {
        return o != null && o.TryBoolProperty(PROPERTY_EXISTING, out var existing) && existing != null && existing.Value;
    }

    /// <summary>
    /// Resources with an <c>import</c> property set to a non-empty string refer to extensibility provided resources.
    /// For example, Microsoft Graph.
    /// </summary>
    /// <param name="o">The resource <seealso cref="JObject"/>.</param>
    /// <returns>Returns <c>true</c> if the resource is imported from an extensibility provider.</returns>
    internal static bool IsImport(this JObject o)
    {
        return o != null && o.TryStringProperty(PROPERTY_IMPORT, out var s) && !string.IsNullOrEmpty(s);
    }

#nullable enable

    /// <summary>
    /// Get the <c>type</c> property from a object.
    /// </summary>
    /// <param name="o">The object to read from.</param>
    /// <param name="type">The value of <c>type</c> if it exists and is a string</param>
    /// <returns>Returns <c>true</c> if the <c>type</c> property exists and is a string.</returns>
    internal static bool TryTypeProperty(this JObject o, out string? type)
    {
        type = default;
        return o != null && o.TryGetProperty(PROPERTY_TYPE, out type);
    }

    /// <summary>
    /// Get the <c>name</c> property from a object.
    /// </summary>
    /// <param name="o">The object to read from.</param>
    /// <param name="name">The value of <c>name</c> if it exists and is a string</param>
    /// <returns>Returns <c>true</c> if the <c>name</c> property exists and is a string.</returns>
    internal static bool TryNameProperty(this JObject o, out string? name)
    {
        name = default;
        return o != null && o.TryGetProperty(PROPERTY_NAME, out name);
    }

    internal static bool TryNameAndType(this JObject o, out string? name, out string? type)
    {
        name = default;
        type = default;
        return o != null && o.TryNameProperty(out name) && o.TryTypeProperty(out type);
    }

    /// <summary>
    /// Get the <c>items.type</c> property from a object.
    /// </summary>
    /// <param name="o">The object to read from.</param>
    /// <param name="itemType">The value of <c>items.type</c> if it exists and is a string</param>
    /// <returns>Returns <c>true</c> if the <c>items.type</c> property exists and is a string.</returns>
    internal static bool TryItemsTypeProperty(this JObject o, out string? itemType)
    {
        itemType = default;
        return o != null && o.TryObjectProperty(PROPERTY_ITEMS, out var items) && items.TryTypeProperty(out itemType);
    }

    /// <summary>
    /// Get the <c>value</c> property from a object.
    /// </summary>
    /// <param name="o">The object to read from.</param>
    /// <param name="value">The value of <c>value</c> if it exists</param>
    /// <returns>Returns <c>true</c> if the <c>value</c> property exists.</returns>
    internal static bool TryValueProperty(this JObject o, out JToken? value)
    {
        value = default;
        return o != null && o.TryGetProperty(PROPERTY_VALUE, out value);
    }

#nullable restore

    /// <summary>
    /// Read the scope from a specified <c>scope</c> property.
    /// </summary>
    /// <param name="resource">The resource object.</param>
    /// <param name="context">A valid context to resolve properties.</param>
    /// <param name="scopeId">The scope if set.</param>
    /// <returns>Returns <c>true</c> if the scope property was set on the resource.</returns>
    internal static bool TryResourceScope(this JObject resource, ITemplateContext context, out string scopeId)
    {
        scopeId = default;
        if (resource == null)
            return false;

        return TryExplicitScope(resource, context, out scopeId)
            || TryExplicitSubscriptionResourceGroupScope(resource, context, out scopeId)
            || TryParentScope(resource, context, out scopeId)
            || TryDeploymentScope(context, out scopeId);
    }

    private static bool TryExplicitScope(JObject resource, ITemplateContext context, out string scopeId)
    {
        scopeId = context.ExpandProperty<string>(resource, PROPERTY_SCOPE);
        if (string.IsNullOrEmpty(scopeId))
            return false;

        // Check for full scope.
        ResourceHelper.ResourceIdComponents(scopeId, out var tenant, out var managementGroup, out var subscriptionId, out var resourceGroup, out var resourceType, out var resourceName);
        if (tenant != null || managementGroup != null || subscriptionId != null)
            return true;

        scopeId = ResourceHelper.ResourceId(resourceType, resourceName, scopeId: context.ScopeId);
        return true;
    }

    /// <summary>
    /// Get the scope from <c>subscriptionId</c> and <c>resourceGroup</c> properties set on the resource.
    /// </summary>
    private static bool TryExplicitSubscriptionResourceGroupScope(JObject resource, ITemplateContext context, out string scopeId)
    {
        var subscriptionId = context.ExpandProperty<string>(resource, PROPERTY_SUBSCRIPTION_ID);
        var resourceGroup = context.ExpandProperty<string>(resource, PROPERTY_RESOURCE_GROUP);

        // Fill subscriptionId if resourceGroup is specified.
        if (!string.IsNullOrEmpty(resourceGroup) && string.IsNullOrEmpty(subscriptionId))
            subscriptionId = context.Subscription.SubscriptionId;

        scopeId = !string.IsNullOrEmpty(subscriptionId) ? ResourceHelper.ResourceId(scopeTenant: null, scopeManagementGroup: null, scopeSubscriptionId: subscriptionId, scopeResourceGroup: resourceGroup, resourceType: null, resourceName: null) : null;
        return scopeId != null;
    }

    /// <summary>
    /// Read the scope from the name and type properties if this is a sub-resource.
    /// For example: A sub-resource may use name segments such as <c>vnet-1/subnet-1</c>.
    /// </summary>
    /// <param name="resource">The resource object.</param>
    /// <param name="context">A valid context to resolve properties.</param>
    /// <param name="scopeId">The calculated scope.</param>
    /// <returns>Returns <c>true</c> if the scope could be calculated from name segments.</returns>
    private static bool TryParentScope(JObject resource, ITemplateContext context, out string scopeId)
    {
        scopeId = null;
        var name = context.ExpandProperty<string>(resource, PROPERTY_NAME);
        var type = context.ExpandProperty<string>(resource, PROPERTY_TYPE);

        if (string.IsNullOrEmpty(name) ||
            string.IsNullOrEmpty(type) ||
            !ResourceHelper.TryResourceIdComponents(type, name, out var resourceTypeComponents, out var nameComponents) ||
            resourceTypeComponents.Length == 1)
            return false;

        scopeId = ResourceHelper.GetParentResourceId(context.Subscription.SubscriptionId, context.ResourceGroup.Name, resourceTypeComponents, nameComponents);
        return true;
    }

    /// <summary>
    /// Get the scope of the resource based on the scope of the deployment.
    /// </summary>
    /// <param name="context">A valid context to resolve the deployment scope.</param>
    /// <param name="scopeId">The scope of the deployment.</param>
    /// <returns>Returns <c>true</c> if a deployment scope was found.</returns>
    private static bool TryDeploymentScope(ITemplateContext context, out string scopeId)
    {
        scopeId = context.Deployment?.Scope;
        return scopeId != null;
    }
}

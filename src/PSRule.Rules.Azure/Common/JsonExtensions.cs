// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure
{
    [DebuggerDisplay("Path: {Path}, Line:{LineNumber}, Position:{LinePosition}")]
    internal sealed class TemplateTokenAnnotation : IJsonLineInfo
    {
        private bool _HasLineInfo;

        public TemplateTokenAnnotation()
        {

        }

        public TemplateTokenAnnotation(int lineNumber, int linePosition, string path)
        {
            SetLineInfo(lineNumber, linePosition);
            Path = path;
        }

        public int LineNumber { get; private set; }

        public int LinePosition { get; private set; }

        public string Path { get; private set; }

        public bool HasLineInfo()
        {
            return _HasLineInfo;
        }

        private void SetLineInfo(int lineNumber, int linePosition)
        {
            LineNumber = lineNumber;
            LinePosition = linePosition;
            _HasLineInfo = true;
        }
    }

    internal static class JsonExtensions
    {
        private const string PROPERTY_DEPENDSON = "dependsOn";
        private const string PROPERTY_RESOURCES = "resources";
        private const string PROPERTY_NAME = "name";
        private const string PROPERTY_TYPE = "type";
        private const string PROPERTY_FIELD = "field";
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

        private static readonly string[] JSON_PATH_SEPARATOR = new string[] { "." };

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

        internal static bool TryGetDependencies(this JObject resource, out string[] dependencies)
        {
            dependencies = null;
            if (!(resource.ContainsKey(PROPERTY_DEPENDSON) && resource[PROPERTY_DEPENDSON] is JArray d && d.Count > 0))
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
            // Get line infomation
            var lineInfo = resource.TryLineInfo();

            // Populate target info
            resource.UseProperty(TARGETINFO_KEY, out JObject targetInfo);

            // Path
            path ??= resource.GetResourcePath();
            targetInfo.Add(TARGETINFO_PATH, path);

            var sources = new JArray();

            // Template file
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
            // Parameter file
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
            if (o.TryGetValue(propertyName, StringComparison.OrdinalIgnoreCase, out var v) && v.Type == JTokenType.Boolean)
            {
                value = v.Value<bool>();
                return value != null;
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
    }
}

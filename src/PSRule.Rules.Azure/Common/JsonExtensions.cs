// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure
{
    internal sealed class TemplateTokenAnnotation : IJsonLineInfo
    {
        private bool _HasLineInfo;

        public TemplateTokenAnnotation()
        {

        }

        public TemplateTokenAnnotation(int lineNumber, int linePosition)
        {
            SetLineInfo(lineNumber, linePosition);
        }

        public int LineNumber { get; private set; }

        public int LinePosition { get; private set; }

        public bool HasLineInfo()
        {
            return _HasLineInfo;
        }
        internal void SetLineInfo(int lineNumber, int linePosition)
        {
            LineNumber = lineNumber;
            LinePosition = linePosition;
            _HasLineInfo = true;
        }
    }

    internal static class JsonExtensions
    {
        private const string PROPERTY_DEPENDSON = "dependsOn";
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

            var annotation = token.Annotation<TemplateTokenAnnotation>();
            if (annotation == null && token is IJsonLineInfo lineInfo && lineInfo.HasLineInfo())
                annotation = new TemplateTokenAnnotation(lineInfo.LineNumber, lineInfo.LinePosition);

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

        internal static bool TryGetProperty<TValue>(this JObject o, string propertyName, out TValue value) where TValue : JToken
        {
            value = null;
            if (o.TryGetValue(propertyName, System.StringComparison.OrdinalIgnoreCase, out var v))
            {
                value = (TValue)v;
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

        internal static void UseProperty<TValue>(this JObject o, string propertyName, out TValue value) where TValue : JToken, new()
        {
            if (!o.TryGetValue(propertyName, System.StringComparison.OrdinalIgnoreCase, out var v))
            {
                value = new TValue();
                o.Add(propertyName, value);
                return;
            }
            value = (TValue)v;
        }

        internal static bool TryGetDependencies(this JObject resource, out string[] dependencies)
        {
            dependencies = null;
            if (!(resource.ContainsKey(PROPERTY_DEPENDSON) && resource[PROPERTY_DEPENDSON] is JArray d && d.Count > 0))
                return false;

            dependencies = d.Values<string>().ToArray();
            return true;
        }

        internal static void SetTargetInfo(this JObject resource, string templateFile, string parameterFile)
        {
            // Get line infomation
            var lineInfo = resource.TryLineInfo();

            // Populate target info
            resource.UseProperty(TARGETINFO_KEY, out JObject targetInfo);

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
    }
}

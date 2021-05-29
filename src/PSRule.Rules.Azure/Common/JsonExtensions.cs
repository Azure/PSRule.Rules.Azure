// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;

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
        private const string FIELD_DEPENDSON = "dependsOn";
        private const string TARGETINFO_NAME = "_PSRule";
        private const string TARGETINFO_SOURCE = "source";
        private const string TARGETINFO_FILE = "file";
        private const string TARGETINFO_LINE = "line";
        private const string TARGETINFO_POSITION = "position";
        private const string TARGETINFO_TYPE = "type";
        private const string TARGETINFO_TYPE_TEMPLATE = "Template";
        private const string TARGETINFO_TYPE_PARAMETER = "Parameter";

        internal static IJsonLineInfo TryLineInfo(this JToken token)
        {
            if (token == null)
                return null;

            var annotation = token.Annotation<TemplateTokenAnnotation>();
            if (annotation != null)
                return annotation;

            return token;
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

        internal static void UseProperty<TValue>(this JObject o, string propertyName, out TValue value) where TValue : JToken, new()
        {
            if (!o.TryGetValue(propertyName, System.StringComparison.OrdinalIgnoreCase, out JToken v))
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
            if (!(resource.ContainsKey(FIELD_DEPENDSON) && resource[FIELD_DEPENDSON] is JArray d && d.Count > 0))
                return false;

            dependencies = d.Values<string>().ToArray();
            return true;
        }

        internal static void SetTargetInfo(this JObject resource, string templateFile, string parameterFile)
        {
            // Get line infomation
            var lineInfo = resource.TryLineInfo();

            // Populate target info
            resource.UseProperty(TARGETINFO_NAME, out JObject targetInfo);

            var sources = new JArray();

            // Template file
            if (!string.IsNullOrEmpty(templateFile))
            {
                var source = new JObject();
                source[TARGETINFO_FILE] = templateFile;
                source[TARGETINFO_TYPE] = TARGETINFO_TYPE_TEMPLATE;
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
                var source = new JObject();
                source[TARGETINFO_FILE] = parameterFile;
                source[TARGETINFO_TYPE] = TARGETINFO_TYPE_PARAMETER;
                if (lineInfo.HasLineInfo())
                {
                    source[TARGETINFO_LINE] = 1;
                }
                sources.Add(source);
            }
            targetInfo.Add(TARGETINFO_SOURCE, sources);
        }
    }
}

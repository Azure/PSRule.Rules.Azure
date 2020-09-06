// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Metadata;
using PSRule.Rules.Azure.Resources;
using System;
using System.Globalization;
using System.IO;
using System.Management.Automation;
using System.Threading;

namespace PSRule.Rules.Azure.Pipeline
{
    public interface ITemplateLinkPipelineBuilder : IPipelineBuilder
    {
        void SkipUnlinked(bool skipUnlinked);
    }

    internal sealed class TemplateLinkPipelineBuilder : PipelineBuilderBase, ITemplateLinkPipelineBuilder
    {
        private readonly string _BasePath;

        private bool _SkipUnlinked;

        internal TemplateLinkPipelineBuilder(string basePath)
        {
            _BasePath = basePath;
        }

        public void SkipUnlinked(bool skipUnlinked)
        {
            _SkipUnlinked = skipUnlinked;
        }

        public override IPipeline Build()
        {
            return new TemplateLinkPipeline(PrepareContext(), PrepareWriter(), _BasePath, _SkipUnlinked);
        }
    }

    internal sealed class TemplateLinkPipeline : PipelineBase
    {
        private const string PROPERTYNAME_SCHEMA = "$schema";
        private const string PROPERTYNAME_METADATA = "metadata";
        private const string PROPERTYNAME_TEMPLATE = "template";
        private const string PROPERTYNAME_NAME = "name";
        private const string PROPERTYNAME_DESCRIPTION = "description";

        private const string DEFAULT_TEMPLATESEARCH_PATTERN = "*.parameters.json";

        private readonly string _BasePath;
        private readonly bool _SkipUnlinked;
        private readonly PathBuilder _PathBuilder;

        internal TemplateLinkPipeline(PipelineContext context, PipelineWriter writer, string basePath, bool skipUnlinked)
            : base(context, writer)
        {
            _BasePath = PSRuleOption.GetRootedBasePath(basePath);
            _SkipUnlinked = skipUnlinked;
            _PathBuilder = new PathBuilder(writer, basePath, DEFAULT_TEMPLATESEARCH_PATTERN);
        }

        public override void Process(PSObject sourceObject)
        {
            if (sourceObject == null || !GetPath(sourceObject, out string path))
                return;

            _PathBuilder.Add(path);
            var fileInfos = _PathBuilder.Build();
            foreach (var info in fileInfos)
                ProcessParameterFile(info.FullName);
        }

        private void ProcessParameterFile(string parameterFile)
        {
            try
            {
                var rootedParameterFile = PSRuleOption.GetRootedPath(parameterFile);

                // Check if metadata property exists
                if (!TryMetadata(rootedParameterFile, out JObject metadata))
                    return;

                if (!TryTemplateFile(metadata, rootedParameterFile, out string templateFile))
                    return;

                var templateLink = new TemplateLink(templateFile, rootedParameterFile);

                // Populate remaining properties
                if (TryStringProperty(metadata, PROPERTYNAME_NAME, out string name))
                    templateLink.Name = name;

                if (TryStringProperty(metadata, PROPERTYNAME_DESCRIPTION, out string description))
                    templateLink.Description = description;

                Writer.WriteObject(templateLink, false);
            }
            catch (InvalidOperationException ex)
            {
                Writer.WriteError(ex, nameof(InvalidOperationException), ErrorCategory.InvalidOperation, parameterFile);
            }
            catch (FileNotFoundException ex)
            {
                Writer.WriteError(ex, nameof(FileNotFoundException), ErrorCategory.ObjectNotFound, parameterFile);
            }
            catch (PipelineException ex)
            {
                Writer.WriteError(ex, nameof(PipelineException), ErrorCategory.WriteError, parameterFile);
            }
        }

        private static bool GetPath(PSObject sourceObject, out string path)
        {
            path = null;
            if (sourceObject.BaseObject is string s)
            {
                path = s;
                return true;
            }
            if (sourceObject.BaseObject is FileInfo info && info.Extension == ".json")
            {
                path = info.FullName;
                return true;
            }
            return false;
        }

        private static T ReadFile<T>(string path)
        {
            if (string.IsNullOrEmpty(path) || !File.Exists(path))
                throw new FileNotFoundException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.ParameterFileNotFound, path), path);

            try
            {
                return JsonConvert.DeserializeObject<T>(File.ReadAllText(path));
            }
            catch (InvalidCastException)
            {
                // Discard exception
                return default(T);
            }
            catch (Exception inner)
            {
                throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.JsonFileFormatInvalid, path, inner.Message), inner, path, null);
            }
        }

        /// <summary>
        /// Check the JSON object is an ARM template parameter file.
        /// </summary>
        private static bool IsParameterFile(JObject value)
        {
            if (!value.TryGetValue(PROPERTYNAME_SCHEMA, out JToken token) || !Uri.TryCreate(token.Value<string>(), UriKind.Absolute, out Uri schemaUri))
                return false;

            return StringComparer.OrdinalIgnoreCase.Equals(schemaUri.Host, "schema.management.azure.com") &&
                StringComparer.OrdinalIgnoreCase.Equals(schemaUri.PathAndQuery, "/schemas/2015-01-01/deploymentParameters.json");
        }

        private bool TryMetadata(string parameterFile, out JObject metadata)
        {
            var parameterObject = ReadFile<JObject>(parameterFile);
            metadata = null;

            // Check that the JSON file is an ARM template parameter file
            if (parameterObject == null || !IsParameterFile(parameterObject))
                return false;

            if (parameterObject.TryGetValue(PROPERTYNAME_METADATA, out JToken metadataToken) && metadataToken is JObject property)
            {
                metadata = property;
                return true;
            }
            Writer.VerboseMetadataNotFound(parameterFile);
            if (!_SkipUnlinked)
                throw new InvalidTemplateLinkException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.MetadataNotFound, parameterFile));

            return false;
        }

        private bool TryTemplateFile(JObject metadata, string parameterFile, out string templateFile)
        {
            if (!(TryStringProperty(metadata, PROPERTYNAME_TEMPLATE, out templateFile)))
            {
                if (_SkipUnlinked)
                {
                    Writer.VerboseTemplateLinkNotFound(parameterFile);
                    return false;
                }
                else throw new InvalidTemplateLinkException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.TemplateLinkNotFound, parameterFile));
            }

            templateFile = TrimSlash(templateFile);
            var pathBase = IsRelative(templateFile) ? Path.GetDirectoryName(parameterFile) : PSRuleOption.GetWorkingPath();
            templateFile = Path.GetFullPath(Path.Combine(pathBase, templateFile));

            // Template file must be within working path
            if (!templateFile.StartsWith(PSRuleOption.GetRootedBasePath(""), StringComparison.Ordinal))
                throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.PathTraversal, templateFile));

            if (!File.Exists(templateFile))
            {
                Writer.VerboseTemplateFileNotFound(templateFile);
                throw new FileNotFoundException(
                    string.Format(CultureInfo.CurrentCulture, PSRuleResources.TemplateFileReferenceNotFound, parameterFile),
                    new FileNotFoundException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.TemplateFileNotFound, templateFile))
                );
            }
            return true;
        }

        private static bool TryStringProperty(JObject o, string propertyName, out string value)
        {
            value = null;
            return o.TryGetValue(propertyName, out JToken token) && TryString(token, out value);
        }

        private static bool TryString(JToken token, out string value)
        {
            value = null;
            if (token == null || token.Type != JTokenType.String)
                return false;

            value = token.Value<string>();
            return true;
        }

        private static bool IsRelative(string path)
        {
            return path.StartsWith("./", StringComparison.OrdinalIgnoreCase) || path.StartsWith("../", StringComparison.OrdinalIgnoreCase);
        }

        private static string TrimSlash(string path)
        {
            return string.IsNullOrEmpty(path) || path[0] != '/' ? path : path.TrimStart('/');
        }
    }
}

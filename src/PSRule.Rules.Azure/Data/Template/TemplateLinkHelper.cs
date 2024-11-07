// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Globalization;
using System.IO;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Metadata;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data.Template
{
    internal sealed class TemplateLinkHelper
    {
        private const string PROPERTYNAME_SCHEMA = "$schema";
        private const string PROPERTYNAME_METADATA = "metadata";
        private const string PROPERTYNAME_TEMPLATE = "template";
        private const string PROPERTYNAME_NAME = "name";
        private const string PROPERTYNAME_DESCRIPTION = "description";

        private const string PARAMETER_FILE_SUFFIX = ".parameters";
        private const string TEMPLATE_FILE_EXTENSION_JSON = ".json";
        private const string TEMPLATE_FILE_EXTENSION_JSONC = ".jsonc";
        private const string TEMPLATE_FILE_EXTENSION_BICEP = ".bicep";

        private const char SLASH = '/';

        private readonly bool _SkipUnlinked;
        private readonly PipelineContext _Context;

        public TemplateLinkHelper(PipelineContext context, string basePath, bool skipUnlinked)
        {
            _Context = context;
            _SkipUnlinked = skipUnlinked;
        }

        internal TemplateLink ProcessParameterFile(string parameterFile)
        {
            // Check that the JSON file is an ARM template parameter file
            var rootedParameterFile = PSRuleOption.GetRootedPath(parameterFile);
            var parameterObject = ReadFile(rootedParameterFile);
            if (parameterObject == null || !IsParameterFile(parameterObject))
                return null;

            // Check if metadata property exists
            if (!(TryMetadata(parameterObject, rootedParameterFile, out var metadata, out var templateFile) ||
                TryTemplateByName(PARAMETER_FILE_SUFFIX, parameterFile, out templateFile)))
            {
                if (metadata == null && !_SkipUnlinked)
                    throw new InvalidTemplateLinkException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.MetadataNotFound, parameterFile));

                if (templateFile == null && !_SkipUnlinked)
                    throw new InvalidTemplateLinkException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.TemplateLinkNotFound, parameterFile));

                return null;
            }

            var templateLink = new TemplateLink(templateFile, rootedParameterFile);

            // Populate remaining properties
            if (TryStringProperty(metadata, PROPERTYNAME_NAME, out var name))
                templateLink.Name = name;

            if (TryStringProperty(metadata, PROPERTYNAME_DESCRIPTION, out var description))
                templateLink.Description = description;

            AddMetadata(templateLink, metadata);
            return templateLink;
        }

        internal static string GetMetadataLinkPath(string parameterFile, string templateFile)
        {
            templateFile = TrimSlash(templateFile);
            var pathBase = IsRelative(templateFile) ? Path.GetDirectoryName(parameterFile) : PSRuleOption.GetWorkingPath();
            templateFile = Path.GetFullPath(Path.Combine(pathBase, templateFile));
            return templateFile;
        }

        private static JObject ReadFile(string path)
        {
            if (string.IsNullOrEmpty(path) || !File.Exists(path))
                throw new FileNotFoundException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.ParameterFileNotFound, path), path);

            try
            {
                return JsonConvert.DeserializeObject(File.ReadAllText(path)) as JObject;
            }
            catch (InvalidCastException)
            {
                // Discard exception
                return null;
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
            return value.TryGetValue(PROPERTYNAME_SCHEMA, out var token) &&
                Uri.TryCreate(token.Value<string>(), UriKind.Absolute, out var schemaUri) &&
                StringComparer.OrdinalIgnoreCase.Equals(schemaUri.Host, "schema.management.azure.com") &&
                schemaUri.PathAndQuery.StartsWith("/schemas/", StringComparison.OrdinalIgnoreCase) &&
                IsDeploymentParameterFile(schemaUri);
        }

        private static bool IsDeploymentParameterFile(Uri schemaUri)
        {
            return schemaUri.PathAndQuery.EndsWith("/deploymentParameters.json", StringComparison.OrdinalIgnoreCase) ||
                schemaUri.PathAndQuery.EndsWith("/subscriptionDeploymentParameters.json", StringComparison.OrdinalIgnoreCase) ||
                schemaUri.PathAndQuery.EndsWith("/managementGroupDeploymentParameters.json", StringComparison.OrdinalIgnoreCase) ||
                schemaUri.PathAndQuery.EndsWith("/tenantDeploymentParameters.json", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Try to find the template file from a root metadata property.
        /// </summary>
        private bool TryMetadata(JObject parameterObject, string parameterFile, out JObject metadata, out string templateFile)
        {
            metadata = null;
            templateFile = null;
            if (parameterObject.TryGetValue(PROPERTYNAME_METADATA, out var metadataToken) && metadataToken is JObject property)
            {
                metadata = property;
                return TryTemplateFile(metadata, parameterFile, out templateFile);
            }
            _Context.Writer.VerboseMetadataNotFound(parameterFile);
            return false;
        }

        private bool TryTemplateFile(JObject metadata, string parameterFile, out string templateFile)
        {
            if (!TryStringProperty(metadata, PROPERTYNAME_TEMPLATE, out templateFile))
            {
                if (_SkipUnlinked)
                    _Context.Writer.VerboseTemplateLinkNotFound(parameterFile);

                return false;
            }

            templateFile = GetMetadataLinkPath(parameterFile, templateFile);

            // Template file must be within working path
            if (!templateFile.StartsWith(PSRuleOption.GetRootedBasePath(""), StringComparison.Ordinal))
                throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.PathTraversal, templateFile));

            if (!File.Exists(templateFile))
            {
                _Context.Writer.VerboseTemplateFileNotFound(templateFile);
                throw new FileNotFoundException(
                    string.Format(CultureInfo.CurrentCulture, PSRuleResources.TemplateFileReferenceNotFound, parameterFile),
                    new FileNotFoundException(string.Format(CultureInfo.CurrentCulture, PSRuleResources.TemplateFileNotFound, templateFile))
                );
            }
            return true;
        }

        /// <summary>
        /// Try to match using templateName.parameters.json.
        /// </summary>
        private static bool TryTemplateByName(string suffix, string parameterFile, out string templateFile)
        {
            templateFile = null;
            var parentPath = Path.GetDirectoryName(parameterFile);
            var filename = Path.GetFileNameWithoutExtension(parameterFile);

            if (string.IsNullOrEmpty(suffix) ||
                string.IsNullOrEmpty(filename) ||
                string.IsNullOrEmpty(parentPath) ||
                filename.Length <= suffix.Length ||
                !filename.EndsWith(suffix, StringComparison.OrdinalIgnoreCase))
                return false;

            var baseFilename = filename.Remove(filename.Length - suffix.Length);
            var jsonTemplateFile = Path.Combine(parentPath, string.Concat(baseFilename, TEMPLATE_FILE_EXTENSION_JSON));
            var jsoncTemplateFile = Path.Combine(parentPath, string.Concat(baseFilename, TEMPLATE_FILE_EXTENSION_JSONC));
            var bicepTemplateFile = Path.Combine(parentPath, string.Concat(baseFilename, TEMPLATE_FILE_EXTENSION_BICEP));
            if (File.Exists(jsonTemplateFile))
            {
                templateFile = jsonTemplateFile;
            }
            else if (File.Exists(jsoncTemplateFile))
            {
                templateFile = jsoncTemplateFile;
            }
            else if (File.Exists(bicepTemplateFile))
            {
                templateFile = bicepTemplateFile;
            }

            return templateFile != null;
        }

        private static bool TryStringProperty(JObject o, string propertyName, out string value)
        {
            value = null;
            return o != null && o.TryGetValue(propertyName, out var token) && TryString(token, out value);
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
            return string.IsNullOrEmpty(path) || path[0] != SLASH ? path : path.TrimStart(SLASH);
        }

        private static void AddMetadata(TemplateLink templateLink, JObject metadata)
        {
            if (metadata == null || templateLink == null)
                return;

            foreach (var prop in metadata.Properties())
            {
                switch (prop.Value.Type)
                {
                    case JTokenType.String:
                        templateLink.Metadata[prop.Name] = prop.Value.Value<string>();
                        break;

                    case JTokenType.Integer:
                        templateLink.Metadata[prop.Name] = prop.Value.Value<long>();
                        break;

                    case JTokenType.Boolean:
                        templateLink.Metadata[prop.Name] = prop.Value.Value<bool>();
                        break;
                }
            }
        }
    }
}

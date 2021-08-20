// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Bicep;
using PSRule.Rules.Azure.Data.Network;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Pipeline.Output;
using System.Management.Automation;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using System.Linq;
using System;

namespace PSRule.Rules.Azure.Runtime
{
    /// <summary>
    /// Helper methods exposed to PowerShell.
    /// </summary>
    public static class Helper
    {
        private readonly static string AssemblyPath = Path.GetDirectoryName(typeof(Helper).Assembly.Location);
        private const string DATAFILE_PROVIDERS = "providers.json";
        private static Dictionary<string, ResourceProvider> _Providers;

        public static string CompressExpression(string expression)
        {
            if (!IsTemplateExpression(expression))
                return expression;

            return ExpressionParser.Parse(expression).AsString();
        }

        public static bool IsTemplateExpression(string expression)
        {
            return ExpressionParser.IsExpression(expression);
        }

        public static PSObject[] GetResources(string parameterFile)
        {
            var context = GetContext();
            var linkHelper = new TemplateLinkHelper(context, PSRuleOption.GetWorkingPath(), true);
            var link = linkHelper.ProcessParameterFile(parameterFile);
            if (link == null)
                return null;

            var helper = new TemplateHelper(context, "helper", context.Option.Configuration.ResourceGroup, context.Option.Configuration.Subscription);
            return helper.ProcessTemplate(link.TemplateFile, link.ParameterFile, out _);
        }

        public static PSObject[] GetBicepResources(string bicepFile, PSCmdlet commandRuntime)
        {
            var context = GetContext(commandRuntime);
            var bicep = new BicepHelper(context, context.Option.Configuration.ResourceGroup, context.Option.Configuration.Subscription);
            return bicep.ProcessFile(bicepFile);
        }

        public static string GetMetadataLinkPath(string parameterFile, string templateFile)
        {
            return TemplateLinkHelper.GetMetadataLinkPath(parameterFile, templateFile);
        }

        public static INetworkSecurityGroupEvaluator GetNetworkSecurityGroup(PSObject[] securityRules)
        {
            var builder = new NetworkSecurityGroupEvaluator();
            builder.With(securityRules);
            return builder;
        }

        #region Helper methods

        private static PipelineContext GetContext(PSCmdlet commandRuntime = null)
        {
            var option = PSRuleOption.FromFileOrDefault(PSRuleOption.GetWorkingPath());
            var context = new PipelineContext(option, commandRuntime != null ? new PSPipelineWriter(option, commandRuntime) : null);
            return context;
        }

        private static Dictionary<string, T> ReadDataFile<T>(string fileName)
        {
            var sourcePath = Path.Combine(AssemblyPath, fileName);
            if (!File.Exists(sourcePath))
                return null;

            var json = File.ReadAllText(sourcePath);
            var settings = new JsonSerializerSettings();
            settings.Converters.Add(new ResourceProviderConverter());
            var result = JsonConvert.DeserializeObject<Dictionary<string, T>>(json, settings);
            return result;
        }

        private static Dictionary<string, ResourceProvider> ReadProviders()
        {
            return ReadDataFile<ResourceProvider>(DATAFILE_PROVIDERS);
        }

        public static ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
        {
            if (_Providers == null)
                _Providers = ReadProviders();

            if (_Providers == null || _Providers.Count == 0 || !_Providers.TryGetValue(providerNamespace, out ResourceProvider provider))
                return Array.Empty<ResourceProviderType>();

            if (resourceType == null)
                return provider.Types.Values.ToArray();

            if (!provider.Types.ContainsKey(resourceType))
                return Array.Empty<ResourceProviderType>();

            return new ResourceProviderType[] { provider.Types[resourceType] };
        }

        #endregion Helper methods
    }
}

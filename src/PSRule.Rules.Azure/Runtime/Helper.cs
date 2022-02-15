// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Bicep;
using PSRule.Rules.Azure.Data.Network;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Pipeline.Output;

namespace PSRule.Rules.Azure.Runtime
{
    /// <summary>
    /// Helper methods exposed to PowerShell.
    /// </summary>
    public static class Helper
    {
        public static string CompressExpression(string expression)
        {
            return !IsTemplateExpression(expression) ? expression : ExpressionParser.Parse(expression).AsString();
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

            return IsBicep(link.TemplateFile) ?
                GetBicepResources(link.TemplateFile, link.ParameterFile, null) :
                GetTemplateResources(link.TemplateFile, link.ParameterFile, context);
        }

        public static PSObject[] GetBicepResources(string bicepFile, PSCmdlet commandRuntime)
        {
            return GetBicepResources(bicepFile, null, commandRuntime);
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

        public static ResourceProviderType[] GetResourceType(string providerNamespace, string resourceType)
        {
            var resourceProviderHelper = new ResourceProviderHelper();
            return resourceProviderHelper.GetResourceType(providerNamespace, resourceType);
        }

        #region Helper methods

        private static PSObject[] GetTemplateResources(string templateFile, string parameterFile, PipelineContext context)
        {
            var helper = new TemplateHelper(
                context,
                "helper"
            );
            return helper.ProcessTemplate(templateFile, parameterFile, out _);
        }

        private static bool IsBicep(string path)
        {
            return Path.GetExtension(path) == ".bicep";
        }

        private static PSObject[] GetBicepResources(string templateFile, string parameterFile, PSCmdlet commandRuntime)
        {
            var context = GetContext(commandRuntime);
            var bicep = new BicepHelper(
                context
            );
            return bicep.ProcessFile(templateFile, parameterFile);
        }

        private static PipelineContext GetContext(PSCmdlet commandRuntime = null)
        {
            var option = PSRuleOption.FromFileOrDefault(PSRuleOption.GetWorkingPath());
            var context = new PipelineContext(option, commandRuntime != null ? new PSPipelineWriter(option, commandRuntime) : null);
            return context;
        }

        #endregion Helper methods
    }
}

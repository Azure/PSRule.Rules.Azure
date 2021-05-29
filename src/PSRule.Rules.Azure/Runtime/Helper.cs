// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using System.Management.Automation;

namespace PSRule.Rules.Azure.Runtime
{
    /// <summary>
    /// Helper methods exposed to PowerShell.
    /// </summary>
    public static class Helper
    {
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

        private static PipelineContext GetContext()
        {
            var option = PSRuleOption.FromFileOrDefault(PSRuleOption.GetWorkingPath());
            var context = new PipelineContext(option, null);
            return context;
        }
    }
}

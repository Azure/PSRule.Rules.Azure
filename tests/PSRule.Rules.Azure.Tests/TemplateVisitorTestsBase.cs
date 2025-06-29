// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Linq;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using static PSRule.Rules.Azure.Arm.Deployments.DeploymentVisitor;

namespace PSRule.Rules.Azure;

#nullable enable

public abstract class TemplateVisitorTestsBase : BaseTests
{
    #region Helper methods

    protected static JObject[] ProcessTemplate(string templateFile, string parametersFile)
    {
        var context = new PipelineContext(PSRuleOption.Default, null);
        var helper = new TemplateHelper(context);
        helper.ProcessTemplate(templateFile, parametersFile, out var templateContext);
        return [.. templateContext.GetResources().Select(i => i.Value)];
    }

    internal static JObject[] ProcessTemplate(string templateFile, string parametersFile, out TemplateContext templateContext, PSRuleOption? option = null)
    {
        var context = new PipelineContext(option ?? PSRuleOption.Default, null);
        var helper = new TemplateHelper(context);
        helper.ProcessTemplate(templateFile, parametersFile, out templateContext);
        return [.. templateContext.GetResources().Select(i => i.Value)];
    }

    protected static JObject[] ProcessTemplate(string templateFile, string parametersFile, PSRuleOption option)
    {
        var context = new PipelineContext(option, null);
        var helper = new TemplateHelper(context);
        helper.ProcessTemplate(templateFile, parametersFile, out var templateContext);
        return [.. templateContext.GetResources().Select(i => i.Value)];
    }

    #endregion Helper methods
}

#nullable restore

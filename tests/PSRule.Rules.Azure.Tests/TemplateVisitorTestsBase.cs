// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure;

public abstract class TemplateVisitorTestsBase
{
    #region Helper methods

    protected static string GetSourcePath(string fileName)
    {
        return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
    }

    protected static JObject[] ProcessTemplate(string templateFile, string parametersFile)
    {
        var context = new PipelineContext(PSRuleOption.Default, null);
        var helper = new TemplateHelper(context);
        helper.ProcessTemplate(templateFile, parametersFile, out var templateContext);
        return templateContext.GetResources().Select(i => i.Value).ToArray();
    }

    internal static JObject[] ProcessTemplate(string templateFile, string parametersFile, out TemplateContext templateContext)
    {
        var context = new PipelineContext(PSRuleOption.Default, null);
        var helper = new TemplateHelper(context);
        helper.ProcessTemplate(templateFile, parametersFile, out templateContext);
        return templateContext.GetResources().Select(i => i.Value).ToArray();
    }

    protected static JObject[] ProcessTemplate(string templateFile, string parametersFile, PSRuleOption option)
    {
        var context = new PipelineContext(option, null);
        var helper = new TemplateHelper(context);
        helper.ProcessTemplate(templateFile, parametersFile, out var templateContext);
        return templateContext.GetResources().Select(i => i.Value).ToArray();
    }

    #endregion Helper methods
}

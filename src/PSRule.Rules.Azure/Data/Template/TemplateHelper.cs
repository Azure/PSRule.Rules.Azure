// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Threading;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm.Deployments;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Resources;
using static PSRule.Rules.Azure.Arm.Deployments.DeploymentVisitor;

namespace PSRule.Rules.Azure.Data.Template;

internal sealed class TemplateHelper(PipelineContext context)
{
    private readonly PipelineContext _Context = context;
    private readonly string _DeploymentName = context.Option.Configuration.Deployment.Name;

    internal PSObject[] ProcessTemplate(string templateFile, string parameterFile, out TemplateContext templateContext)
    {
        var rootedTemplateFile = PSRuleOption.GetRootedPath(templateFile);
        if (!File.Exists(rootedTemplateFile))
            throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateFileNotFound, rootedTemplateFile), rootedTemplateFile);

        var templateObject = ReadFile(rootedTemplateFile);
        var visitor = new MaterializedDeploymentVisitor();

        // Load context
        templateContext = new TemplateContext(_Context);
        if (!string.IsNullOrEmpty(parameterFile))
        {
            var rootedParameterFile = PSRuleOption.GetRootedPath(parameterFile);
            if (!File.Exists(rootedParameterFile))
                throw new FileNotFoundException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.ParameterFileNotFound, rootedParameterFile), rootedParameterFile);

            try
            {
                var parametersObject = ReadFile(rootedParameterFile);
                templateContext.Load(parametersObject);
            }
            catch (Exception inner)
            {
                throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateExpandInvalid, templateFile, parameterFile, inner.Message), inner, templateFile, parameterFile);
            }
        }

        // Process
        try
        {
            templateContext.SetSource(templateFile, parameterFile);
            visitor.Visit(templateContext, _DeploymentName, templateObject);
        }
        catch (Exception inner)
        {
            throw new TemplateReadException(string.Format(Thread.CurrentThread.CurrentCulture, PSRuleResources.TemplateExpandInvalid, templateFile, parameterFile, inner.Message), inner, templateFile, parameterFile);
        }

        // Return results
        var results = new List<PSObject>();
        var serializer = new JsonSerializer();
        serializer.Converters.Add(new PSObjectJsonConverter());
        foreach (var resource in templateContext.GetResources())
            results.Add(resource.Value.ToObject<PSObject>(serializer));

        return results.ToArray();
    }

    private static JObject ReadFile(string path)
    {
        using var stream = new StreamReader(path);
        using var reader = new JsonTextReader(stream);
        return JObject.Load(reader);
    }
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Pipeline;

internal sealed class TemplateLinkPipeline : PipelineBase
{
    private const string DEFAULT_TEMPLATESEARCH_PATTERN = "*.parameters.json";

    private readonly string _BasePath;
    private readonly PathBuilder _PathBuilder;
    private readonly TemplateLinkHelper _TemplateHelper;

    internal TemplateLinkPipeline(PipelineContext context, string basePath, bool skipUnlinked)
        : base(context)
    {
        _BasePath = PSRuleOption.GetRootedBasePath(basePath);
        _PathBuilder = new PathBuilder(context.Writer, basePath, DEFAULT_TEMPLATESEARCH_PATTERN);
        _TemplateHelper = new TemplateLinkHelper(context, _BasePath, skipUnlinked);
    }

    /// <inheritdoc/>
    public override void Process(PSObject sourceObject)
    {
        if (sourceObject == null || !sourceObject.GetPath(out var path))
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
            var templateLink = _TemplateHelper.ProcessParameterFile(parameterFile);
            Context.Writer.WriteObject(templateLink, false);
        }
        catch (InvalidOperationException ex)
        {
            Context.Writer.WriteError(ex, nameof(InvalidOperationException), ErrorCategory.InvalidOperation, parameterFile);
        }
        catch (FileNotFoundException ex)
        {
            Context.Writer.WriteError(ex, nameof(FileNotFoundException), ErrorCategory.ObjectNotFound, parameterFile);
        }
        catch (PipelineException ex)
        {
            Context.Writer.WriteError(ex, nameof(PipelineException), ErrorCategory.WriteError, parameterFile);
        }
    }
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Bicep;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Runtime;

namespace PSRule.Rules.Azure.Pipeline;

internal sealed class TemplatePipeline : PipelineBase
{
    private TemplateHelper _TemplateHelper;
    private BicepHelper _BicepHelper;

    internal TemplatePipeline(PipelineContext context)
        : base(context) { }

    /// <inheritdoc/>
    public override void Process(PSObject sourceObject)
    {
        if (sourceObject == null || sourceObject.BaseObject is not TemplateSource source)
            return;

        if (source.ParametersFile == null || source.ParametersFile.Length == 0)
            ProcessCatch(source.TemplateFile, null, source.Kind);
        else
            for (var i = 0; i < source.ParametersFile.Length; i++)
                ProcessCatch(source.TemplateFile, source.ParametersFile[i], source.Kind);
    }

    private void ProcessCatch(string templateFile, string parameterFile, TemplateSourceKind kind)
    {
        try
        {
            if (kind == TemplateSourceKind.Bicep)
            {
                Context.Writer.WriteObject(ProcessBicep(templateFile, parameterFile), true);
            }
            else if (kind == TemplateSourceKind.BicepParam)
            {
                Context.Writer.WriteObject(ProcessBicepParam(templateFile), true);
            }
            else
            {
                Context.Writer.WriteObject(ProcessTemplate(templateFile, parameterFile), true);
            }
        }
        catch (PipelineException ex)
        {
            Context.Writer.WriteError(ex, nameof(PipelineException), ErrorCategory.InvalidData, parameterFile);
        }
        catch
        {
            throw;
        }
    }

    private PSObject[] ProcessTemplate(string templateFile, string parameterFile)
    {
        return GetTemplateHelper().ProcessTemplate(templateFile, parameterFile, out _);
    }

    private PSObject[] ProcessBicep(string templateFile, string parameterFile)
    {
        return GetBicepHelper().ProcessFile(templateFile, parameterFile);
    }

    private PSObject[] ProcessBicepParam(string parameterFile)
    {
        return GetBicepHelper().ProcessParamFile(parameterFile);
    }

    private TemplateHelper GetTemplateHelper()
    {
        return _TemplateHelper ??= new TemplateHelper(Context);
    }

    private BicepHelper GetBicepHelper()
    {
        return _BicepHelper ??= new BicepHelper(Context, new RuntimeService(
            minimum: Context.Option.Configuration.BicepMinimumVersion ?? ConfigurationOption.Default.BicepMinimumVersion,
            timeout: Context.Option.Configuration.BicepFileExpansionTimeout.GetValueOrDefault(ConfigurationOption.Default.BicepFileExpansionTimeout.Value)
        ));
    }
}

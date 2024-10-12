// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline.Output;

namespace PSRule.Rules.Azure.Pipeline;

internal abstract class PipelineBuilderBase : IPipelineBuilder
{
    private readonly PSPipelineWriter _Output;

    protected readonly PSRuleOption Option;

    protected PSCmdlet CmdletContext;
    protected EngineIntrinsics ExecutionContext;

    protected PipelineBuilderBase()
    {
        Option = new PSRuleOption();
        _Output = new PSPipelineWriter(Option);
    }

    /// <inheritdoc/>
    public virtual void UseCommandRuntime(PSCmdlet commandRuntime)
    {
        CmdletContext = commandRuntime;
        _Output.UseCommandRuntime(commandRuntime);
    }

    /// <inheritdoc/>
    public void UseExecutionContext(EngineIntrinsics executionContext)
    {
        ExecutionContext = executionContext;
        _Output.UseExecutionContext(executionContext);
    }

    /// <inheritdoc/>
    public virtual IPipelineBuilder Configure(PSRuleOption option)
    {
        if (option == null)
            return this;

        Option.Output = new OutputOption(option.Output);
        Option.Configuration = new ConfigurationOption(option.Configuration);
        return this;
    }

    /// <inheritdoc/>
    public abstract IPipeline Build();

    protected PipelineContext PrepareContext()
    {
        return new PipelineContext(Option, PrepareWriter());
    }

    protected virtual PipelineWriter PrepareWriter()
    {
        var writer = new PSPipelineWriter(Option);
        writer.UseCommandRuntime(CmdletContext);
        writer.UseExecutionContext(ExecutionContext);
        return writer;
    }

    protected virtual PipelineWriter GetOutput()
    {
        return _Output;
    }
}

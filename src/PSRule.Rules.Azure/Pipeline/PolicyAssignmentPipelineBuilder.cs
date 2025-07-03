// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline.Output;

namespace PSRule.Rules.Azure.Pipeline;

#nullable enable

internal sealed class PolicyAssignmentPipelineBuilder : PipelineBuilderBase, IPolicyAssignmentPipelineBuilder
{
    private bool _PassThru;
    private bool _KeepDuplicates;
    private const string OUTPUT_FILE_PREFIX = "definitions-";
    private const string OUTPUT_FILE_EXTENSION = ".Rule.jsonc";
    private const string ASSIGNMENT_NAME_PREFIX = "export-";
    private string _AssignmentName;

    internal PolicyAssignmentPipelineBuilder(PSRuleOption option)
    {
        _AssignmentName = string.Concat(ASSIGNMENT_NAME_PREFIX, Guid.NewGuid().ToString().Substring(0, 8));
        Configure(option);
    }

    public void Assignment(string assignmentName)
    {
        if (string.IsNullOrEmpty(assignmentName))
            return;

        _AssignmentName = assignmentName;
    }

    public void ResourceGroup(ResourceGroupOption resourceGroup)
    {
        if (resourceGroup == null)
            return;

        Option.Configuration.ResourceGroup = ResourceGroupOption.Combine(resourceGroup, Option.Configuration.ResourceGroup);
    }

    public void Subscription(SubscriptionOption subscription)
    {
        if (subscription == null)
            return;

        Option.Configuration.Subscription = SubscriptionOption.Combine(subscription, Option.Configuration.Subscription);
    }

    /// <inheritdoc/>
    public void PassThru(bool passThru)
    {
        _PassThru = passThru;
    }

    /// <inheritdoc/>
    public void KeepDuplicates(bool keepDuplicates)
    {
        _KeepDuplicates = keepDuplicates;
    }

    protected override PipelineWriter GetOutput()
    {
        // Redirect to file instead
        return !string.IsNullOrEmpty(Option.Output.Path)
            ? new FileOutputWriter(
                inner: base.GetOutput(),
                option: Option,
                encoding: Option.Output.Encoding.GetEncoding(),
                path: Option.Output.Path,
                defaultFile: string.Concat(OUTPUT_FILE_PREFIX, _AssignmentName, OUTPUT_FILE_EXTENSION),
                shouldProcess: CmdletContext.ShouldProcess
            )
            : base.GetOutput();
    }

    protected override PipelineWriter PrepareWriter()
    {
        return _PassThru ? base.PrepareWriter() : new JsonOutputWriter(GetOutput(), Option);
    }

    /// <inheritdoc/>
    public override IPipeline Build()
    {
        return new PolicyAssignmentPipeline(PrepareContext(), _KeepDuplicates);
    }
}

#nullable restore

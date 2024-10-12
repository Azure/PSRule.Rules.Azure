// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;

namespace PSRule.Rules.Azure.Pipeline;

internal sealed class PolicyAssignmentSearchPipeline : PipelineBase
{
    private const string DEFAULT_ASSIGNMENTSEARCH_PATTERN = "*.assignment.json";
    private readonly PathBuilder _PathBuilder;

    internal PolicyAssignmentSearchPipeline(PipelineContext context, string basePath)
        : base(context)
    {
        _PathBuilder = new PathBuilder(context.Writer, basePath, DEFAULT_ASSIGNMENTSEARCH_PATTERN);
    }

    /// <inheritdoc/>
    public override void Process(PSObject sourceObject)
    {
        if (sourceObject == null || !sourceObject.GetPath(out var path))
            return;

        _PathBuilder.Add(path);
        var fileInfos = _PathBuilder.Build();
        foreach (var info in fileInfos)
            ProcessAssignmentFile(info.FullName);
    }

    private void ProcessAssignmentFile(string assignmentFile)
    {
        var assignmentSource = new PolicyAssignmentSource(assignmentFile);
        Context.Writer.WriteObject(assignmentSource, false);
    }
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;
using PSRule.Rules.Azure.Data.Policy;

namespace PSRule.Rules.Azure.Pipeline
{
    internal sealed class PolicyAssignmentPipeline : PipelineBase
    {
        private readonly PolicyAssignmentHelper _PolicyAssignmentHelper;

        internal PolicyAssignmentPipeline(PipelineContext context)
            : base(context)
        {
            _PolicyAssignmentHelper = new PolicyAssignmentHelper(context);
        }

        /// <inheritdoc/>
        public override void Process(PSObject sourceObject)
        {
            if (sourceObject == null || !(sourceObject.BaseObject is PolicyAssignmentSource source))
                return;

            ProcessCatch(source.AssignmentFile);
        }

        private void ProcessCatch(string assignmentFile)
        {
            try
            {
                Context.Writer.WriteObject(ProcessAssignment(assignmentFile), true);
            }
            catch (PipelineException ex)
            {
                Context.Writer.WriteError(
                    ex,
                    nameof(PipelineException),
                    ErrorCategory.InvalidData,
                    assignmentFile);
            }
            catch
            {
                throw;
            }
        }

        internal PolicyDefinition[] ProcessAssignment(string assignmentFile)
        {
            return _PolicyAssignmentHelper.ProcessAssignment(assignmentFile, out _);
        }
    }
}

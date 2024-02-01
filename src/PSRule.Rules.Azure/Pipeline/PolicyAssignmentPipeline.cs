// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;
using PSRule.Rules.Azure.Data.Policy;

namespace PSRule.Rules.Azure.Pipeline
{
    internal sealed class PolicyAssignmentPipeline : PipelineBase
    {
        private readonly PolicyAssignmentHelper _PolicyAssignmentHelper;

        internal PolicyAssignmentPipeline(PipelineContext context, bool keepDuplicates)
            : base(context)
        {
            _PolicyAssignmentHelper = new PolicyAssignmentHelper(context, keepDuplicates);
        }

        /// <inheritdoc/>
        public override void Process(PSObject sourceObject)
        {
            if (sourceObject == null || sourceObject.BaseObject is not PolicyAssignmentSource source)
                return;

            ProcessCatch(source.AssignmentFile);
        }

        private void ProcessCatch(string assignmentFile)
        {
            try
            {
                ProcessAssignment(assignmentFile);
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

        private void ProcessAssignment(string assignmentFile)
        {
            Context.Writer.WriteObject(_PolicyAssignmentHelper.ProcessAssignment(assignmentFile, out var context), true);
            Context.Writer.WriteObject(context.GenerateBaseline(), false);
        }
    }
}

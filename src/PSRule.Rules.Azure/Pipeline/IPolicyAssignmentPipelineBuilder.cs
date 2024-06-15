// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline
{
    /// <summary>
    /// A builder for a policy assignment export pipeline.
    /// </summary>
    public interface IPolicyAssignmentPipelineBuilder : IPipelineBuilder
    {
        /// <summary>
        /// Enable pass-through of output from the pipeline.
        /// </summary>
        /// <param name="passThru">Enable pass-through.</param>
        void PassThru(bool passThru);

        /// <summary>
        /// Determines if policy definitions that duplicate existing built-in rules are exported.
        /// </summary>
        /// <param name="keepDuplicates">Enable exporting duplicates.</param>
        void KeepDuplicates(bool keepDuplicates);
    }
}

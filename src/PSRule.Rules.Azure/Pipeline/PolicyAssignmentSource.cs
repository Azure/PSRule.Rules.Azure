// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline
{
    public sealed class PolicyAssignmentSource
    {
        internal readonly string AssignmentFile;

        public PolicyAssignmentSource(string assignmentFile)
        {
            AssignmentFile = assignmentFile;
        }
    }
}
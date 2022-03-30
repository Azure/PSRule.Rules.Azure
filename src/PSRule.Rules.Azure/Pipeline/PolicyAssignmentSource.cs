// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline
{
    public sealed class PolicyAssignmentSource
    {
        public string AssignmentFile { get; }

        public PolicyAssignmentSource(string assignmentFile)
        {
            AssignmentFile = assignmentFile;
        }
    }
}
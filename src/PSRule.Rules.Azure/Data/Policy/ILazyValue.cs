// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Policy
{
    internal interface ILazyValue
    {
        object GetValue(PolicyAssignmentVisitor.PolicyAssignmentContext context);
    }
}

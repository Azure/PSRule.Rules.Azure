// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace PSRule.Rules.Azure.Data
{
    internal sealed class PolicyIgnoreResult
    {
        public PolicyIgnoreReason Reason { get; set; }

        public List<string> Value { get; set; }
    }
}

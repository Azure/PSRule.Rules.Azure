// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data;

internal enum PolicyIgnoreReason
{
    /// <summary>
    /// The policy is excluded because it was duplicated with an existing rule.
    /// </summary>
    Duplicate = 1,

    /// <summary>
    /// The policy is excluded because it is not testable or not applicable for IaC.
    /// </summary>
    NotApplicable = 2,

    /// <summary>
    /// An exclusion configured by the user.
    /// </summary>
    Configured = 3
}

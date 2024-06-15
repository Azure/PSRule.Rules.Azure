// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Network
{
    /// <summary>
    /// The result after evaluating a rule.
    /// </summary>
    public enum Access
    {
        /// <summary>
        /// The result is denies or allowed based on NSG defaults.
        /// A specific NSG rule has not been configured to allow or deny.
        /// </summary>
        Default = 0,

        /// <summary>
        /// Access has been permitted.
        /// </summary>
        Allow = 1,

        /// <summary>
        /// Access has been denied.
        /// </summary>
        Deny = 2
    }
}

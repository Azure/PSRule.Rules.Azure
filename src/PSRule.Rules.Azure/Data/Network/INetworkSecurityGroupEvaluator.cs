// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Network
{
    /// <summary>
    /// Evaluates NSG rules to determine resulting access.
    /// </summary>
    public interface INetworkSecurityGroupEvaluator
    {
        /// <summary>
        /// Determine the resulting outbound access after evaluating NSG rules.
        /// </summary>
        Access Outbound(string prefix, int port);
    }
}

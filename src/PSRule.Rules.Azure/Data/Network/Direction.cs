// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Network;

/// <summary>
/// The direction of network traffic.
/// </summary>
internal enum Direction
{
    /// <summary>
    /// Inbound network traffic.
    /// </summary>
    Inbound = 1,

    /// <summary>
    /// Outbound network traffic.
    /// </summary>
    Outbound = 2
}

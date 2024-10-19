// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;

namespace PSRule.Rules.Azure.Data.Network;

/// <summary>
/// A network security rule.
/// </summary>
/// <param name="direction">The direction of the traffic.</param>
/// <param name="access">The result access if the rule matches.</param>
/// <param name="destinationAddressPrefixes">Destination prefixes this rule applies to.</param>
/// <param name="destinationPortRanges">Destination port ranges this rule applies to.</param>
internal sealed class SecurityRule(Direction direction, Access access, string[] destinationAddressPrefixes, string[] destinationPortRanges)
{
    public Access Access { get; } = access;

    public Direction Direction { get; } = direction;

    public HashSet<string> DestinationAddressPrefixes { get; } = destinationAddressPrefixes == null ? null : new HashSet<string>(destinationAddressPrefixes, StringComparer.OrdinalIgnoreCase);

    public HashSet<string> DestinationPortRanges { get; } = destinationPortRanges == null ? null : new HashSet<string>(destinationPortRanges, StringComparer.OrdinalIgnoreCase);

    internal bool TryDestinationPrefix(string prefix)
    {
        return DestinationAddressPrefixes == null || DestinationAddressPrefixes.Contains(prefix);
    }

    internal bool TryDestinationPort(int port)
    {
        return DestinationPortRanges == null || DestinationPortRanges.Contains(port.ToString());
    }
}

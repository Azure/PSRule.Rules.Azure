// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace PSRule.Rules.Azure.Data.Network;

#nullable enable

/// <summary>
/// A basic implementation of an evaluator for checking NSG rules.
/// </summary>
internal sealed partial class NetworkSecurityGroupEvaluator : INetworkSecurityGroupEvaluator
{
    private const string PROPERTIES = "properties";
    private const string DIRECTION = "direction";
    private const string ACCESS = "access";
    private const string DESTINATION_ADDRESS_PREFIX = "destinationAddressPrefix";
    private const string DESTINATION_ADDRESS_PREFIXES = "destinationAddressPrefixes";
    private const string DESTINATION_PORT_RANGE = "destinationPortRange";
    private const string DESTINATION_PORT_RANGES = "destinationPortRanges";
    private const string ANY = "*";

    private readonly List<SecurityRule> _Outbound;

    internal NetworkSecurityGroupEvaluator()
    {
        _Outbound = [];
    }

    public void With(PSObject[] items)
    {
        if (items == null || items.Length == 0)
            return;

        for (var i = 0; i < items.Length; i++)
        {
            var r = GetRule(items[i]);
            if (r.Direction == Direction.Outbound)
                _Outbound.Add(r);
        }
    }

    /// <inheritdoc/>
    public Access Outbound(string prefix, int port)
    {
        for (var i = 0; i < _Outbound.Count; i++)
        {
            if (_Outbound[i].TryDestinationPrefix(prefix) && _Outbound[i].TryDestinationPort(port))
                return _Outbound[i].Access;
        }
        return Access.Default;
    }

    private static SecurityRule GetRule(PSObject o)
    {
        var properties = o.GetPropertyValue<PSObject>(PROPERTIES);
        var direction = (Direction)Enum.Parse(typeof(Direction), properties.GetPropertyValue<string>(DIRECTION), ignoreCase: true);
        var access = (Access)Enum.Parse(typeof(Access), properties.GetPropertyValue<string>(ACCESS), ignoreCase: true);
        var destinationAddressPrefixes = GetFilter(properties, DESTINATION_ADDRESS_PREFIX) ?? GetFilter(properties, DESTINATION_ADDRESS_PREFIXES);
        var destinationPortRanges = GetFilter(properties, DESTINATION_PORT_RANGE) ?? GetFilter(properties, DESTINATION_PORT_RANGES);
        var result = new SecurityRule
        (
            direction,
            access,
            destinationAddressPrefixes,
            destinationPortRanges
        );
        return result;
    }

    private static string[]? GetFilter(PSObject o, string propertyName)
    {
        if (o.TryProperty(propertyName, out string[] value) && value.Length > 0)
            return value;

        return o.TryProperty(propertyName, out string s) && s != ANY ? [s] : null;
    }
}

#nullable restore

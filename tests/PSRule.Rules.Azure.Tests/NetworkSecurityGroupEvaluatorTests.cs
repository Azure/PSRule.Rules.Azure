// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;

namespace PSRule.Rules.Azure.Data.Network;

#nullable enable

public sealed class NetworkSecurityGroupEvaluatorTests
{
    [Fact]
    public void Outbound_WhenMatchingRule_ShouldReturnAccess()
    {
        var evaluator = new NetworkSecurityGroupEvaluator();
        evaluator.With([Rule(access: "Deny", destinationAddressPrefix: "VirtualNetwork", destinationPortRanges: ["3389"])]);

        Assert.Equal(Access.Deny, evaluator.Outbound("VirtualNetwork", 3389));
    }

    [Fact]
    public void With_WhenDestinationPortRangeIsEmptyString_ShouldUseDestinationPortRanges()
    {
        var evaluator = new NetworkSecurityGroupEvaluator();
        evaluator.With([Rule(access: "Deny", destinationPortRange: "", destinationPortRanges: ["80", "443"])]);

        Assert.Equal(Access.Deny, evaluator.Outbound("Virtual Network", 443));
    }

    #region Helper methods

    private static PSObject Rule(string direction = "Outbound", string access = "Allow", string protocol = "Tcp", string? destinationAddressPrefix = default, string? destinationPortRange = default, string[]? destinationPortRanges = default)
    {
        var properties = new PSObject();
        properties.Properties.Add(new PSNoteProperty("direction", direction));
        properties.Properties.Add(new PSNoteProperty("access", access));
        properties.Properties.Add(new PSNoteProperty("protocol", protocol));
        properties.Properties.Add(new PSNoteProperty("destinationAddressPrefix", destinationAddressPrefix));

        if (destinationPortRange != null)
            properties.Properties.Add(new PSNoteProperty("destinationPortRange", destinationPortRange));

        if (destinationPortRanges != null)
            properties.Properties.Add(new PSNoteProperty("destinationPortRanges", destinationPortRanges));

        var result = new PSObject();
        result.Properties.Add(new PSNoteProperty("properties", properties));
        return result;
    }

    #endregion Helper methods
}

#nullable restore

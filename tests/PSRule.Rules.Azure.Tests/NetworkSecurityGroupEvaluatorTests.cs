// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;

namespace PSRule.Rules.Azure.Data.Network;

#nullable enable

public sealed class NetworkSecurityGroupEvaluatorTests
{
    [Fact]
    public void With_WhenDestinationPortRangeIsEmptyString_ShouldUseDestinationPortRanges()
    {
        var evaluator = new NetworkSecurityGroupEvaluator();
        evaluator.With([NewRule(destinationPortRange: "", destinationPortRanges: ["80", "443"])]);

        Assert.Equal(Access.Deny, evaluator.Outbound("Virtual Network", 443));
    }

    #region Helper methods

    private static PSObject NewRule(string? destinationPortRange = default, string[]? destinationPortRanges = default)
    {
        var properties = new PSObject();
        properties.Properties.Add(new PSNoteProperty("direction", "Outbound"));
        properties.Properties.Add(new PSNoteProperty("access", "Deny"));

        if (destinationPortRange != null)
            properties.Properties.Add(new PSNoteProperty("destinationPortRange", destinationPortRange));

        if (destinationPortRanges != null)
            properties.Properties.Add(new PSNoteProperty("destinationPortRanges", destinationPortRanges));

        var o = new PSObject();
        o.Properties.Add(new PSNoteProperty("properties", properties));
        return o;
    }

    #endregion Helper methods
}

#nullable restore

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Firewall
#

#region Rules

# Synopsis: Deploy firewall instances using availability zones in supported regions to ensure high availability and resilience.
Rule 'Azure.Firewall.AvailabilityZone' -Ref 'AZR-000429' -Type 'Microsoft.Network/azureFirewalls' -Tag @{ release = 'GA'; ruleSet = '2024_06 '; 'Azure.WAF/pillar' = 'Reliability'; } {
    # Check if the region supports availability zones.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Network', 'azureFirewalls')
    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $provider.ZoneMappings

    # Don't flag if the region does not support availability zones.
    if (-not $availabilityZones) {
        return $Assert.Pass()
    }

    $Assert.GreaterOrEqual($TargetObject, 'zones', 2).Reason(
        $LocalizedData.AzFWAvailabilityZone,
        $TargetObject.name,
        $TargetObject.location,
        ($availabilityZones -join ', ')
    )
}

#endregion Rules

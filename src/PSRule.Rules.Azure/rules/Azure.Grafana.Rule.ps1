# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Managed Grafana
#

#region Rules

# Synopsis: Use zone redundant Grafana workspaces in supported regions to improve reliability.
Rule 'Azure.Grafana.AvailabilityZone' -Ref 'AZR-000501' -Type 'Microsoft.Dashboard/grafana' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    # Check for availability zones based on virtual machine scale set, because it is not exposed through the provider for Grafana.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');
    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $provider.ZoneMappings;

    # Don't flag if the region does not support AZ.
    if (-not $availabilityZones) {
        return $Assert.Pass();
    }

    $Assert.HasFieldValue($TargetObject, 'properties.zoneRedundancy', 'Enabled');
}

#endregion Rules

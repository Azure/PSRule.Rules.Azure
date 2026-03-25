# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Fleet
#

#region Rules

# Synopsis: Use SSH keys instead of common credentials to secure Linux Azure Fleet VMs against malicious activities.
Rule 'Azure.Fleet.PublicKey' -Ref 'AZR-000535' -Type 'Microsoft.AzureFleet/fleets' -If { FleetHasLinuxOS } -Tag @{ release = 'GA'; ruleSet = '2026_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-4' } {
    $Assert.In($TargetObject, 'properties.computeProfile.baseVirtualMachineProfile.osProfile.linuxConfiguration.disablePasswordAuthentication', $True).
    Reason($LocalizedData.FleetPublicKey, $PSRule.TargetName)
}

#endregion Rules

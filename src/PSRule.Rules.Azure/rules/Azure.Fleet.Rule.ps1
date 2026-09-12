# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Fleet
#

#region Rules

# Synopsis: Use SSH keys instead of common credentials to secure Linux Azure Fleet VMs against malicious activities.
Rule 'Azure.Fleet.PublicKey' -Ref 'AZR-000541' -Type 'Microsoft.AzureFleet/fleets' -If { FleetHasLinuxOS } -Tag @{ release = 'GA'; ruleSet = '2026_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.WAF/maturity' = 'L2'; } {
    $Assert.In($TargetObject, 'properties.computeProfile.baseVirtualMachineProfile.osProfile.linuxConfiguration.disablePasswordAuthentication', $True).
    Reason($LocalizedData.FleetPublicKey, $PSRule.TargetName)
}


# Synopsis: Azure Fleet VM profiles should use Trusted Launch with Secure Boot enabled.
Rule 'Azure.Fleet.SecureBoot' -Ref 'AZR-000545' -Type 'Microsoft.AzureFleet/fleets' -Tag @{ release = 'GA'; ruleSet = '2026_09'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.WAF/maturity' = 'L2' } {
    $Assert.In($TargetObject, 'properties.computeProfile.baseVirtualMachineProfile.securityProfile.securityType', @('TrustedLaunch', 'ConfidentialVM')).
        Reason($LocalizedData.FleetSecureBoot, $PSRule.TargetName)
    $Assert.HasFieldValue($TargetObject, 'properties.computeProfile.baseVirtualMachineProfile.securityProfile.uefiSettings.secureBootEnabled', $True).
        Reason($LocalizedData.FleetSecureBootEnabled, $PSRule.TargetName)
}

#endregion Rules

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Microsoft Defender for Cloud
#

#region Rules

# Synopsis: Microsoft Defender for Cloud email and phone contact details should be set
Rule 'Azure.DefenderCloud.Contact' -Alias 'Azure.SecurityCenter.Contact' -Ref 'AZR-000209' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    Reason $LocalizedData.SecurityCenterNotConfigured;
    $contacts = @(GetSubResources -ResourceType 'Microsoft.Security/securityContacts');
    $Null -ne $contacts -and $contacts.Length -gt 0;
    foreach ($c in $contacts) {
        $Assert.HasFieldValue($c, 'Properties.Email')
        $Assert.HasFieldValue($c, 'Properties.Phone');
    }
}

# Synopsis: Enable auto-provisioning on VMs to improve Microsoft Defender for Cloud insights
Rule 'Azure.DefenderCloud.Provisioning' -Alias 'Azure.SecurityCenter.Provisioning' -Ref 'AZR-000210' -Type 'Microsoft.Subscription' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'LT-4' } {
    $provisioning = @(GetSubResources -ResourceType 'Microsoft.Security/autoProvisioningSettings');
    $Null -ne $provisioning -and $provisioning.Length -gt 0;
    foreach ($s in $provisioning) {
        $Assert.HasFieldValue($s, 'Properties.autoProvision', 'On');
    }
}

# Synopsis: Enable Malware Scanning in Microsoft Defender for Storage.
Rule 'Azure.Defender.Storage.MalwareScan' -Ref  'AZR-000383' -Type 'Microsoft.Security/pricings' -If { IsNotClassicStoragePlan } -Tag @{ release = 'Preview'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-2', 'LT-1' } {
    $malwareConfigured = @($TargetObject.properties.extensions |
        Where-Object name -eq 'OnUploadMalwareScanning' |
        Where-Object isEnabled -eq 'True')
    $Assert.GreaterOrEqual($malwareConfigured, '.', 1).Reason($LocalizedData.SubStorageMalwareScanning)
}

# Synopsis: Enable sensitive data threat detection in Microsoft Defender for Storage.
Rule 'Azure.Defender.Storage.SensitiveData' -Ref  'AZR-000385' -Type 'Microsoft.Security/pricings' -If { IsNotClassicStoragePlan } -Tag @{ release = 'Preview'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-2', 'LT-1' } {
    $sensitiveConfigured = @($TargetObject.properties.extensions |
        Where-Object name -eq 'SensitiveDataDiscovery' |
        Where-Object isEnabled -eq 'True')
    $Assert.GreaterOrEqual($sensitiveConfigured, '.', 1).Reason($LocalizedData.SubStorageSensitiveDataThreatDetection)
}

#endregion Rules

#region Helper functions

function global:IsNotClassicStoragePlan {
    [CmdletBinding()]
    param ()
    process {
        if ($PSRule.TargetName -eq 'StorageAccounts') {
            $TargetObject.properties.subPlan -eq 'DefenderForStorageV2'
        }
    }
}

#endregion Helper functions

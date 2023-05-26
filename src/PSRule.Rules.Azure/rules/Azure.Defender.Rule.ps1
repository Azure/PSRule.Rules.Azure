# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Microsoft Defender for Cloud
#

#region Rules

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

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Recovery Services Vault (RSV)
#

# Synopsis: Recovery Services Vault (RSV) not using geo-replicated storage (GRS) may be at risk.
Rule 'Azure.RSV.StorageType' -Type 'Microsoft.RecoveryServices/vaults', 'Microsoft.RecoveryServices/vaults/backupconfig' -Tag @{ release = 'GA'; ruleSet = '2022_03' } {
    $backupConfig = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.RecoveryServices/vaults') {
        $backupConfig = @(GetSubResources -ResourceType 'Microsoft.RecoveryServices/vaults/backupconfig');
    }

    if ($backupConfig.Length -eq 0) {
        return $Assert.Pass();
    }

    if($backupConfig.Properties.storageType){
        write-host $backupConfig.name
        write-host "backupConfig.Properties.storageType Value:"
        write-host $backupConfig.Properties.storageType
        write-host "TargetObject.Properties.storageType Value:"
        write-host $TargetObject.Properties.storageType
        $Assert.In($backupConfig, 'Properties.storageType', @(
            'ReadAccessGeoZoneRedundant',
            'GeoRedundant'
        ));
    } else {
        return $Assert.Pass();
    }
}

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Recovery Services Vault (RSV)
#

# Synopsis: Recovery Services Vault (RSV) not using geo-replicated storage (GRS) may be at risk.
Rule 'Azure.RSV.StorageType' -Type 'Microsoft.RecoveryServices/vaults', 'Microsoft.RecoveryServices/vaults/backupconfig' -Tag @{ release = 'GA'; ruleSet = '2022_03' } {
    if($TargetObject.Properties.storageType){
        $Assert.In($TargetObject, 'properties.storageType', @(
            'ReadAccessGeoZoneRedundant'
            'GeoRedundant'
        ));
    } else {
        return $Assert.Pass();
    }
}

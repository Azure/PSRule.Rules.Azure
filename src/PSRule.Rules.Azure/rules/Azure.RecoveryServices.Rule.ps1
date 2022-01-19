# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Recovery Services Vault
#

# Synopsis: Recovery Services Vault not using geo-replicated storage (GRS) may be at risk.
Rule 'Azure.RecoveryServices.StorageType' -Type 'Microsoft.RecoveryServices/vaults/backupconfig' -Tag @{ release = 'GA'; ruleSet = '2022_03' } {
    # Verify that the storageType property is set, if so verify it's set to use Geo-replicated Storage
    if ( $TargetObject, 'properties.storageType' ) {
        $Assert.In($TargetObject, 'properties.storageType', @(
            'ReadAccessGeoZoneRedundant'
            'GeoRedundant'
        ));
    }
}


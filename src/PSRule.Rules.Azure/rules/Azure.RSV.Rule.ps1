# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Recovery Services Vault (RSV)
#

# Synopsis: Recovery Services Vault (RSV) not using geo-replicated storage (GRS) may be at risk.
Rule 'Azure.RSV.StorageType' -Ref 'AZR-000170' -Type 'Microsoft.RecoveryServices/vaults', 'Microsoft.RecoveryServices/vaults/backupconfig' -Tag @{ release = 'GA'; ruleSet = '2022_03'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $backupConfig = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.RecoveryServices/vaults') {
        $backupConfig = @(GetSubResources -ResourceType 'Microsoft.RecoveryServices/vaults/backupconfig');
    }

    if ($backupConfig.Length -eq 0) {
        return $Assert.Pass();
    }

    foreach ($config in $backupConfig) {
        $Assert.AnyOf(
            $Assert.NotHasField($config, 'Properties.storageType'),
            $Assert.In($config, 'Properties.storageType', @(
                'ReadAccessGeoZoneRedundant',
                'GeoRedundant'
            ))
        )
    }
}

# Synopsis: Recovery Services Vault (RSV) without a replication alert may be at risk.
Rule 'Azure.RSV.ReplicationAlert' -Ref 'AZR-000171' -Type 'Microsoft.RecoveryServices/vaults', 'Microsoft.RecoveryServices/vaults/replicationAlertSettings' -Tag @{ release = 'GA'; ruleSet = '2022_03'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $replicationAlert = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.RecoveryServices/vaults') {
        $replicationAlert = @(GetSubResources -ResourceType 'Microsoft.RecoveryServices/vaults/replicationAlertSettings');
    }

    foreach ($alert in $replicationAlert) {
        $Assert.AnyOf(
            $Assert.HasFieldValue($alert, 'Properties.sendToOwners', 'Send'),
            $Assert.HasFieldValue($alert, 'Properties.customEmailAddresses')
        )
    }
}


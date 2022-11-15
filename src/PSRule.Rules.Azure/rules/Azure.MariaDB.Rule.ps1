# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Database for MariaDB
#

#region Rules

# Synopsis: Azure Database for MariaDB should store backups in a geo-redundant storage.
Rule 'Azure.MariaDB.GeoRedundantBackup' -Ref 'AZR-000329' -Type 'Microsoft.DBforMariaDB/servers' -If { HasMariaDBTierSupportingGeoRedundantBackup } -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.storageProfile.geoRedundantBackup', 'Enabled').
    Reason($LocalizedData.MariaDBGeoRedundantBackupNotConfigured, $PSRule.TargetName)
}

#endregion Rules

#region Helper functions

function global:HasMariaDBTierSupportingGeoRedundantBackup {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        $Assert.in($TargetObject, 'sku.tier', @('GeneralPurpose', 'MemoryOptimized')).Result
    }
}

#endregion Helper functions

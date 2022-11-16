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


# Synopsis: Azure Database for MariaDB servers should reject TLS versions older than 1.2.
Rule 'Azure.MariaDB.MinTLS' -Ref 'AZR-000333' -Type 'Microsoft.DBforMariaDB/servers' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.minimalTlsVersion', 'TLS1_2').
    Reason($LocalizedData.MinTLSVersion, $TargetObject.properties.minimalTlsVersion)
}

# Synopsis: Azure Database for MariaDB resources should meet naming requirements.
Rule 'Azure.MariaDB.ServerName' -Ref 'AZR-000334' -Type 'Microsoft.DBforMariaDB/servers', 'Microsoft.DBforMariaDB/servers/databases', 'Microsoft.DBforMariaDB/servers/firewallRules', 'Microsoft.DBforMariaDB/servers/virtualNetworkRules' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    # https://learn.microsoft.com/nb-no/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb

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

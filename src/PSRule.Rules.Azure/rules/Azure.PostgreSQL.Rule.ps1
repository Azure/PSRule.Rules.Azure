# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Database for PostgreSQL
#

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.PostgreSQL.FirewallRuleCount' -Ref 'AZR-000149' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules');
    $Assert.
        LessOrEqual($firewallRules, '.', 10).
        WithReason(($LocalizedData.DBServerFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.PostgreSQL.AllowAzureAccess' -Ref 'AZR-000150' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules' | Where-Object {
        $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0')
    })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.PostgreSQL.FirewallIPRange' -Ref 'AZR-000151' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $summary = GetIPAddressSummary
    $Assert.
        LessOrEqual($summary, 'Public', 10).
        WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True);
}

# Synopsis: Azure SQL logical server names should meet naming requirements.
Rule 'Azure.PostgreSQL.ServerName' -Ref 'AZR-000152' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    # https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbforpostgresql

    # Between 3 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){2,62}$', $True);
}

# Synopsis: Azure Database for PostgreSQL should store backups in a geo-redundant storage.
Rule 'Azure.PostgreSQL.GeoRedundantBackup' -Ref 'AZR-000326' -Type 'Microsoft.DBforPostgreSQL/flexibleServers', 'Microsoft.DBforPostgreSQL/servers' -If { HasPostgreSQLTierSupportingGeoRedundantBackup } -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    if ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/flexibleServers') {
        $Assert.HasFieldValue($TargetObject, 'properties.backup.geoRedundantBackup', 'Enabled').
        Reason($LocalizedData.PostgreSQLGeoRedundantBackupNotConfigured, $PSRule.TargetName)
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/servers') {
        $Assert.HasFieldValue($TargetObject, 'properties.storageProfile.geoRedundantBackup', 'Enabled').
        Reason($LocalizedData.PostgreSQLGeoRedundantBackupNotConfigured, $PSRule.TargetName)
    }
}

#region Helper functions

function global:HasPostgreSQLTierSupportingGeoRedundantBackup {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/flexibleServers') {
            $True
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/servers') {
            $Assert.in($TargetObject, 'sku.tier', @('GeneralPurpose', 'MemoryOptimized')).Result
        }
    }
}

#endregion Helper functions

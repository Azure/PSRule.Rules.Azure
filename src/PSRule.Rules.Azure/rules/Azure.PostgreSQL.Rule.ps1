# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Database for PostgreSQL
#

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.PostgreSQL.FirewallRuleCount' -Ref 'AZR-000149' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules');
    $Assert.
    LessOrEqual($firewallRules, '.', 10).
    WithReason(($LocalizedData.ExceededFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.PostgreSQL.AllowAzureAccess' -Ref 'AZR-000150' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules' | Where-Object {
            $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0')
        })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.PostgreSQL.FirewallIPRange' -Ref 'AZR-000151' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $summary = GetIPAddressSummary
    $Assert.
    LessOrEqual($summary, 'Public', 10).
    WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True);
}

# Synopsis: Azure SQL logical server names should meet naming requirements.
Rule 'Azure.PostgreSQL.ServerName' -Ref 'AZR-000152' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } -Labels @{ 'Azure.CAF' = 'naming' } {
    # https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbforpostgresql

    # Between 3 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){2,62}$', $True);
}

# Synopsis: Azure Database for PostgreSQL should store backups in a geo-redundant storage.
Rule 'Azure.PostgreSQL.GeoRedundantBackup' -Ref 'AZR-000326' -Type 'Microsoft.DBforPostgreSQL/flexibleServers', 'Microsoft.DBforPostgreSQL/servers' -If { HasPostgreSQLTierSupportingGeoRedundantBackup } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    if ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/flexibleServers') {
        $Assert.HasFieldValue($TargetObject, 'properties.backup.geoRedundantBackup', 'Enabled').
        Reason($LocalizedData.PostgreSQLGeoRedundantBackupNotConfigured, $PSRule.TargetName)
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/servers') {
        $Assert.HasFieldValue($TargetObject, 'properties.storageProfile.geoRedundantBackup', 'Enabled').
        Reason($LocalizedData.PostgreSQLGeoRedundantBackupNotConfigured, $PSRule.TargetName)
    }
}

# Synopsis: Enable Microsoft Defender for Cloud for Azure Database for PostgreSQL.
Rule 'Azure.PostgreSQL.DefenderCloud' -Ref 'AZR-000327' -Type 'Microsoft.DBforPostgreSQL/servers', 'Microsoft.DBforPostgreSQL/servers/securityAlertPolicies' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    if ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/servers') {
        $defenderConfigs = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/securityAlertPolicies')
        if ($defenderConfigs.Length -eq 0) {
            $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.DBforPostgreSQL/servers/securityAlertPolicies')
        }
        foreach ($defenderConfig in $defenderConfigs) {
            $Assert.HasFieldValue($defenderConfig, 'properties.state', 'Enabled').
            PathPrefix('resources')
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/servers/securityAlertPolicies') {
        $Assert.HasFieldValue($TargetObject, 'properties.state', 'Enabled')
    }
}

# Synopsis: Use Azure Active Directory (AAD) authentication with Azure Database for PostgreSQL databases.
Rule 'Azure.PostgreSQL.AAD' -Ref 'AZR-000389' -Type 'Microsoft.DBforPostgreSQL/flexibleServers', 'Microsoft.DBforPostgreSQL/servers', 'Microsoft.DBforPostgreSQL/flexibleServers/administrators', 'Microsoft.DBforPostgreSQL/servers/administrators' -Tag @{ release = 'GA'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1'; 'Azure.WAF/maturity' = 'L1'; } {
    switch ($PSRule.TargetType) {
        'Microsoft.DBforPostgreSQL/flexibleServers' { PostgreSQLFlexibleServerAAD }
        'Microsoft.DBforPostgreSQL/servers' { PostgreSQLSingleServerAAD }
        'Microsoft.DBforPostgreSQL/flexibleServers/administrators' { PostgreSQLFlexibleServerAAD }
        'Microsoft.DBforPostgreSQL/servers/administrators' { PostgreSQLSingleServerAAD }
    }
}

# Synopsis: Deploy Azure Database for PostgreSQL servers using zone-redundant high availability (HA) in supported regions to ensure high availability and resilience.
Rule 'Azure.PostgreSQL.ZoneRedundantHA' -Ref 'AZR-000434' -Type 'Microsoft.DBforPostgreSQL/flexibleServers' -Tag @{ release = 'GA'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    # Check if the region supports availability zones.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.DBforPostgreSQL', 'flexibleServers')
    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $provider.ZoneMappings

    # Don't flag if the region does not support availability zones.
    if (-not $availabilityZones) {
        return $Assert.Pass()
    }

    $supportedSku = @('GeneralPurpose', 'MemoryOptimized')
    if ($TargetObject.sku.tier -notin $supportedSku) {
        return $Assert.In($TargetObject, 'sku.tier', $supportedSku) # Zone-redundant HA is only supported for the GeneralPurpose and MemoryOptimized SKU tiers.
    }

    $Assert.HasFieldValue($TargetObject, 'properties.highAvailability.mode', 'ZoneRedundant')
}

#endregion SQL Managed Instance

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

function global:PostgreSQLFlexibleServerAAD {
    [CmdletBinding()]
    param ()
    if ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/flexibleServers') {
        $configs = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/flexibleServers/administrators')
        if ($configs.Count -eq 0) {
             return $Assert.Fail().Reason($LocalizedData.SubResourceNotFound, 'Microsoft.DBforPostgreSQL/flexibleServers/administrators')
        }
        
        foreach ($config in $configs) {
            $Assert.HasFieldValue($config, 'properties.principalName')
            $Assert.HasFieldValue($config, 'properties.principalType')
            $Assert.HasFieldValue($config, 'properties.tenantId')
        }
    }
    else {
        $Assert.HasFieldValue($TargetObject, 'properties.principalName')
        $Assert.HasFieldValue($TargetObject, 'properties.principalType')
        $Assert.HasFieldValue($TargetObject, 'properties.tenantId')
    }
}

function global:PostgreSQLSingleServerAAD {
    [CmdletBinding()]
    param ()
    if ($PSRule.TargetType -eq 'Microsoft.DBforPostgreSQL/servers') {
        $configs = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/administrators' -Name 'ActiveDirectory')
        if ($configs.Count -eq 0) {
            return $Assert.Fail().Reason($LocalizedData.SubResourceNotFound, 'Microsoft.DBforPostgreSQL/servers/administrators')
       }
        
        foreach ($config in $configs) {
            $Assert.HasFieldValue($config, 'properties.administratorType', 'ActiveDirectory')
            $Assert.HasFieldValue($config, 'properties.login')
            $Assert.HasFieldValue($config, 'properties.sid')
            $Assert.HasFieldValue($config, 'properties.tenantId')
        }
    }
    else {
        $Assert.HasFieldValue($TargetObject, 'properties.administratorType', 'ActiveDirectory')
        $Assert.HasFieldValue($TargetObject, 'properties.login')
        $Assert.HasFieldValue($TargetObject, 'properties.sid')
        $Assert.HasFieldValue($TargetObject, 'properties.tenantId')
    }
}

#endregion Helper functions

#region Naming rules

# Synopsis: PostgreSQL databases without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.PostgreSQL.ServerNaming' -Ref 'AZR-000522' -Type 'Microsoft.DBforPostgreSQL/servers', 'Microsoft.DBforPostgreSQL/flexibleServers' -If { $Configuration['AZURE_POSTGRESQL_SERVER_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_POSTGRESQL_SERVER_NAME_FORMAT, $True);
}

#endregion Naming rules

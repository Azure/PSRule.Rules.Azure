# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Database for MySQL
#

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.MySQL.FirewallRuleCount' -Ref 'AZR-000133' -Type 'Microsoft.DBforMySQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforMySQL/servers/firewallRules');
    $Assert.
    LessOrEqual($firewallRules, '.', 10).
    WithReason(($LocalizedData.ExceededFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.MySQL.AllowAzureAccess' -Ref 'AZR-000134' -Type 'Microsoft.DBforMySQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforMySQL/servers/firewallRules' | Where-Object {
            $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0')
        })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.MySQL.FirewallIPRange' -Ref 'AZR-000135' -Type 'Microsoft.DBforMySQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $summary = GetIPAddressSummary
    $Assert.
    LessOrEqual($summary, 'Public', 10).
    WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True);
}

# Synopsis: Azure SQL logical server names should meet naming requirements.
Rule 'Azure.MySQL.ServerName' -Ref 'AZR-000136' -Type 'Microsoft.DBforMySQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformysql

    # Between 3 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){2,62}$', $True);
}

# Synopsis: Azure Database for MySQL should store backups in a geo-redundant storage.
Rule 'Azure.MySQL.GeoRedundantBackup' -Ref 'AZR-000323' -Type 'Microsoft.DBforMySQL/flexibleServers', 'Microsoft.DBforMySQL/servers' -If { HasMySQLTierSupportingGeoRedundantBackup } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    if ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/flexibleServers') {
        $Assert.HasFieldValue($TargetObject, 'properties.backup.geoRedundantBackup', 'Enabled').
        Reason($LocalizedData.MySQLGeoRedundantBackupNotConfigured, $PSRule.TargetName)
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/servers') {
        $Assert.HasFieldValue($TargetObject, 'properties.storageProfile.geoRedundantBackup', 'Enabled').
        Reason($LocalizedData.MySQLGeoRedundantBackupNotConfigured, $PSRule.TargetName)
    }
}

# Synopsis: Use Azure Database for MySQL Flexible Server deployment model.
Rule 'Azure.MySQL.UseFlexible' -Ref 'AZR-000325' -Type 'Microsoft.DBforMySQL/flexibleServers', 'Microsoft.DBforMySQL/servers' -Level Warning -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.Create($PSRule.TargetType -eq 'Microsoft.DBforMySQL/flexibleServers', $LocalizedData.SingleDeploymentModelRetirement)
}

# Synopsis: Enable Microsoft Defender for Cloud for Azure Database for MySQL.
Rule 'Azure.MySQL.DefenderCloud' -Ref 'AZR-000328' -Type 'Microsoft.DBforMySQL/servers', 'Microsoft.DBforMySQL/servers/securityAlertPolicies' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    if ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/servers') {
        $defenderConfigs = @(GetSubResources -ResourceType 'Microsoft.DBforMySQL/servers/securityAlertPolicies')
        if ($defenderConfigs.Length -eq 0) {
            $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.DBforMySQL/servers/securityAlertPolicies')
        }
        foreach ($defenderConfig in $defenderConfigs) {
            $Assert.HasFieldValue($defenderConfig, 'properties.state', 'Enabled').
            PathPrefix('resources')
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/servers/securityAlertPolicies') {
        $Assert.HasFieldValue($TargetObject, 'properties.state', 'Enabled')
    }
}

# Synopsis: Use Azure Active Directory (AAD) authentication with Azure Database for MySQL databases.
Rule 'Azure.MySQL.AAD' -Ref 'AZR-000392' -Type 'Microsoft.DBforMySQL/flexibleServers', 'Microsoft.DBforMySQL/servers', 'Microsoft.DBforMySQL/flexibleServers/administrators', 'Microsoft.DBforMySQL/servers/administrators' -Tag @{ release = 'GA'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1' } {
    switch ($PSRule.TargetType) {
        'Microsoft.DBforMySQL/flexibleServers' { MySQLFlexibleServerAAD }
        'Microsoft.DBforMySQL/servers' { MySQLSingleServerAAD }
        'Microsoft.DBforMySQL/flexibleServers/administrators' { MySQLFlexibleServerAAD }
        'Microsoft.DBforMySQL/servers/administrators' { MySQLSingleServerAAD }
    }
}

# Synopsis: Ensure Azure AD-only authentication is enabled with Azure Database for MySQL databases.
Rule 'Azure.MySQL.AADOnly' -Ref 'AZR-000394' -Type 'Microsoft.DBforMySQL/flexibleServers', 'Microsoft.DBforMySQL/flexibleServers/configurations' -Tag @{ release = 'GA'; ruleSet = '2023_09'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1' } {
    if ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/flexibleServers') {
        $configurations = @(GetSubResources -ResourceType 'Microsoft.DBforMySQL/flexibleServers/configurations' -Name "aad_auth_only")
        if ($configurations.Count -eq 0) {
            return $Assert.Fail().Reason($LocalizedData.SubResourceNotFound, 'Microsoft.DBforMySQL/flexibleServers/configurations')
        }

        foreach ($config in $configurations) {
            if ($Assert.HasFieldValue($config, 'properties.value').Result) {
                $Assert.HasFieldValue($config, 'properties.value', 'ON')  
            }
            else {
                $Assert.HasFieldValue($config, 'properties.currentValue', 'ON')
            }
        }
    }
    elseif ($PSRule.TargetName.Split('/')[-1] -cmatch 'aad_auth_only') {
        if ($Assert.HasFieldValue($TargetObject, 'properties.value').Result) {
            $Assert.HasFieldValue($TargetObject, 'properties.value', 'ON')  
        }
        else {
            $Assert.HasFieldValue($TargetObject, 'properties.currentValue', 'ON')
        }
    }
    else {
        $Assert.Pass()
    }
}

#region Helper functions

function global:HasMySQLTierSupportingGeoRedundantBackup {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/flexibleServers') {
            $True
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/servers') {
            $Assert.In($TargetObject, 'sku.tier', @('GeneralPurpose', 'MemoryOptimized')).Result
        }
    }
}

function global:MySQLFlexibleServerAAD {
    [CmdletBinding()]
    param ()
    if ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/flexibleServers') {
        $configs = @(GetSubResources -ResourceType 'Microsoft.DBforMySQL/flexibleServers/administrators' -Name 'ActiveDirectory')
        if ($configs.Count -eq 0) {
            return $Assert.Fail().Reason($LocalizedData.SubResourceNotFound, 'Microsoft.DBforMySQL/flexibleServers/administrators')
        }

        foreach ($config in $configs) {
            $Assert.HasFieldValue($config, 'properties.administratorType', 'ActiveDirectory')
            $Assert.HasFieldValue($config, 'properties.identityResourceId')
            $Assert.HasFieldValue($config, 'properties.login')
            $Assert.HasFieldValue($config, 'properties.sid')
            $Assert.HasFieldValue($config, 'properties.tenantId')
        }
    }
    else {
        $Assert.HasFieldValue($TargetObject, 'properties.administratorType', 'ActiveDirectory')
        $Assert.HasFieldValue($TargetObject, 'properties.identityResourceId')
        $Assert.HasFieldValue($TargetObject, 'properties.login')
        $Assert.HasFieldValue($TargetObject, 'properties.sid')
        $Assert.HasFieldValue($TargetObject, 'properties.tenantId')
    }
}

function global:MySQLSingleServerAAD {
    [CmdletBinding()]
    param ()
    if ($PSRule.TargetType -eq 'Microsoft.DBforMySQL/servers') {
        $configs = @(GetSubResources -ResourceType 'Microsoft.DBforMySQL/servers/administrators' -Name 'ActiveDirectory')
        if ($configs.Count -eq 0) {
            return $Assert.Fail().Reason($LocalizedData.SubResourceNotFound, 'Microsoft.DBforMySQL/servers/administrators')
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

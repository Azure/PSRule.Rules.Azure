# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure SQL Database
#

#region SQL Logical Server

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.SQL.FirewallRuleCount' -Ref 'AZR-000183' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/firewallRules');
    $Assert.
    LessOrEqual($firewallRules, '.', 10).
    WithReason(($LocalizedData.ExceededFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.SQL.AllowAzureAccess' -Ref 'AZR-000184' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/firewallRules' | Where-Object {
            $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.StartIpAddress -eq '0.0.0.0' -and $_.properties.EndIpAddress -eq '0.0.0.0')
        })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.SQL.FirewallIPRange' -Ref 'AZR-000185' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $summary = GetIPAddressSummary
    $Assert.
    LessOrEqual($summary, 'Public', 10).
    WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True);
}

# Synopsis: Enable Microsoft Defender for Cloud for Azure SQL logical server
Rule 'Azure.SQL.DefenderCloud' -Alias 'Azure.SQL.ThreatDetection' -Ref 'AZR-000186' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-3' } {
    $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/securityAlertPolicies');
    if ($configs.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Sql/servers/securityAlertPolicies');
    }
    foreach ($config in $configs) {
        $Assert.HasFieldValue($config, 'Properties.state', 'Enabled');
    }
}

# Synopsis: Enable auditing for Azure SQL logical server.
Rule 'Azure.SQL.Auditing' -Ref 'AZR-000187' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'LT-3' } {
    $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/auditingSettings');
    if ($configs.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Sql/servers/auditingSettings');
    }
    foreach ($config in $configs) {
        $Assert.HasFieldValue($config, 'Properties.state', 'Enabled');
    }
}

# Synopsis: Use Azure Active Directory (AAD) authentication with Azure SQL databases.
Rule 'Azure.SQL.AAD' -Ref 'AZR-000188' -Type 'Microsoft.Sql/servers', 'Microsoft.Sql/servers/administrators' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1' } {
    # NB: Microsoft.Sql/servers/administrators overrides properties.administrators property.

    $configs = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Sql/servers') {
        $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/administrators' -Name 'ActiveDirectory');
        Write-Verbose -Message "Using type 'Microsoft.Sql/servers' with $($configs.Length).";
    }

    if ($configs.Length -eq 0 -and $PSRule.TargetType -eq 'Microsoft.Sql/servers') {
        $Assert.HasFieldValue($TargetObject, 'properties.administrators.administratorType', 'ActiveDirectory');
        $Assert.HasFieldValue($TargetObject, 'properties.administrators.login');
        $Assert.HasFieldValue($TargetObject, 'properties.administrators.sid');
    }
    else {
        foreach ($config in $configs) {
            $Assert.HasFieldValue($config, 'properties.administratorType', 'ActiveDirectory');
            $Assert.HasFieldValue($config, 'properties.login');
            $Assert.HasFieldValue($config, 'properties.sid');
        }
    }
}

# Synopsis: Azure SQL logical server names should meet naming requirements.
Rule 'Azure.SQL.ServerName' -Ref 'AZR-000190' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql

    # Between 1 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){0,62}$', $True);
}

# Synopsis: Ensure Azure AD-only authentication is enabled with Azure SQL Database.
Rule 'Azure.SQL.AADOnly' -Ref 'AZR-000369' -Type 'Microsoft.Sql/servers', 'Microsoft.Sql/servers/azureADOnlyAuthentications' -Tag @{ release = 'GA'; ruleSet = '2023_03'; 'Azure.WAF/pillar' = 'Security'; } {
    $types = 'Microsoft.Sql/servers', 'Microsoft.Sql/servers/azureADOnlyAuthentications'
    $enabledAADOnly = @(GetAzureSQLADOnlyAuthentication -ResourceType $types | Where-Object { $_ })
    $Assert.GreaterOrEqual($enabledAADOnly, '.', 1).Reason($LocalizedData.AzureADOnlyAuthentication)
}

#endregion SQL Logical Server

#region SQL Database

# Synopsis: Enable transparent data encryption
Rule 'Azure.SQL.TDE' -Ref 'AZR-000191' -Type 'Microsoft.Sql/servers/databases', 'Microsoft.Sql/servers/databases/transparentDataEncryption' -If { !(IsMasterDatabase) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-3' } {
    $configs = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Sql/servers/databases') {
        $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/databases/transparentDataEncryption');
    }
    if ($configs.Length -eq 0) {
        if (!(IsExport)) {
            return $Assert.Pass();
        }
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Sql/servers/databases/transparentDataEncryption');
    }
    foreach ($config in $configs) {
        if ($Assert.HasField($config, 'Properties.status').Result) {
            $Assert.HasFieldValue($config, 'Properties.status', 'Enabled');
        }
        else {
            $Assert.HasFieldValue($config, 'Properties.state', 'Enabled');
        }
    }
}

# Synopsis: Azure SQL Database names should meet naming requirements.
Rule 'Azure.SQL.DBName' -Ref 'AZR-000192' -Type 'Microsoft.Sql/servers/databases' -If { !(IsExport) } -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql

    $name = $PSRule.TargetName.Split('/', 2, [System.StringSplitOptions]::RemoveEmptyEntries)[-1];

    # Between 1 and 128 characters long
    $Assert.GreaterOrEqual($name, '.', 1);
    $Assert.LessOrEqual($name, '.', 128);

    # Can't use: <>*%&:\/?
    # Can't end with period or space
    $Assert.Match($name, '.', '^(\w|[-=+!$()@~`]|\s|\.){0,127}(\w|[-=+!$()@~`])$');

    # Exclude reserved names
    $Assert.NotIn($name, '.', @('master', 'model', 'tempdb'));
}

#endregion SQL Database

#region Failover group

# Synopsis: Azure SQL failover group names should meet naming requirements.
Rule 'Azure.SQL.FGName' -Ref 'AZR-000193' -Type 'Microsoft.Sql/servers/failoverGroups' -If { !(IsExport) } -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql

    $name = $PSRule.TargetName.Split('/')[-1];

    # Between 1 and 63 characters long
    $Assert.GreaterOrEqual($name, '.', 1);
    $Assert.LessOrEqual($name, '.', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($name, '.', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){0,62}$', $True);
}

#endregion Failover group

#region Maintenance window

# Synopsis: Configure a customer-controlled maintenance window for Azure SQL databases.
Rule 'Azure.SQL.MaintenanceWindow' -Ref 'AZR-000440' -Type 'Microsoft.Sql/servers', 'Microsoft.Sql/servers/databases', 'Microsoft.Sql/servers/elasticPools' -Tag @{ release = 'GA'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    if ($PSRule.TargetType -eq 'Microsoft.Sql/servers') {
        # Microsoft.Sql/servers/elasticPools maintenance configuration is inherited to all databases within the pool, so we only need to check databases that is not in a pool.
        $resources = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/databases', 'Microsoft.Sql/servers/elasticPools' | Where-Object { -not $_.properties.psobject.Properties['elasticPoolId'] })

        if ($resources.Count -eq 0) {
            return $Assert.Pass()
        }

        foreach ($resource in $resources) {
            $Assert.Match($resource, 'properties.maintenanceConfigurationId', '\/publicMaintenanceConfigurations\/SQL_[A-Za-z]+[A-Za-z0-9]*_DB_[12]$', $True).
            Reason(
                $LocalizedData.AzureSQLDatabaseMaintenanceWindow,
                $(if ($resource.type -eq 'Microsoft.Sql/servers/databases') { 'database' } else { 'elastic pool' }),
                $resource.Name
            ).PathPrefix('resources')
        }
    }

    elseif ($PSRule.TargetType -eq 'Microsoft.Sql/servers/databases') {
        $Assert.Match($TargetObject, 'properties.maintenanceConfigurationId', '\/publicMaintenanceConfigurations\/SQL_[A-Za-z]+[A-Za-z0-9]*_DB_[12]$', $True).
        Reason(
            $LocalizedData.AzureSQLDatabaseMaintenanceWindow,
            'database',
            $TargetObject.Name
        )
    }

    # Microsoft.Sql/servers/elasticPools maintenance configuration is inherited to all databases within the pool.
    else {
        $Assert.Match($TargetObject, 'properties.maintenanceConfigurationId', '\/publicMaintenanceConfigurations\/SQL_[A-Za-z]+[A-Za-z0-9]*_DB_[12]$', $True).
        Reason(
            $LocalizedData.AzureSQLDatabaseMaintenanceWindow,
            'elastic pool',
            $TargetObject.Name
        )
    }
}

#endregion Manintenance window

#region Helper functions

function global:IsMasterDatabase {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return (
            $PSRule.TargetType -eq 'Microsoft.Sql/servers/databases' -and (
                $PSRule.TargetName -like '*/master' -or
                $PSRule.TargetName -eq 'master'
            )
        );
    }
}

#endregion Helper functions

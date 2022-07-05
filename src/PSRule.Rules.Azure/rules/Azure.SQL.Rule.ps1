# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure SQL Database
#

#region SQL Logical Server

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.SQL.FirewallRuleCount' -Ref 'AZR-000183' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/firewallRules');
    $Assert.
        LessOrEqual($firewallRules, '.', 10).
        WithReason(($LocalizedData.DBServerFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.SQL.AllowAzureAccess' -Ref 'AZR-000184' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/firewallRules' | Where-Object {
        $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.StartIpAddress -eq '0.0.0.0' -and $_.properties.EndIpAddress -eq '0.0.0.0')
    })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.SQL.FirewallIPRange' -Ref 'AZR-000185' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $summary = GetIPAddressSummary
    $Assert.
        LessOrEqual($summary, 'Public', 10).
        WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True);
}

# Synopsis: Enable Advanced Thread Protection for Azure SQL logical server
Rule 'Azure.SQL.ThreatDetection' -Ref 'AZR-000186' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/securityAlertPolicies');
    if ($configs.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Sql/servers/securityAlertPolicies');
    }
    foreach ($config in $configs) {
        $Assert.HasFieldValue($config, 'Properties.state', 'Enabled');
    }
}

# Synopsis: Enable auditing for Azure SQL logical server
Rule 'Azure.SQL.Auditing' -Ref 'AZR-000187' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/auditingSettings');
    if ($configs.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Sql/servers/auditingSettings');
    }
    foreach ($config in $configs) {
        $Assert.HasFieldValue($config, 'Properties.state', 'Enabled');
    }
}

# Synopsis: Use Azure AD administrators
Rule 'Azure.SQL.AAD' -Ref 'AZR-000188' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/administrators');
    if ($configs.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Sql/servers/administrators');
    }
    foreach ($config in $configs) {
        $Assert.HasFieldValue($config, 'Properties.administratorType', 'ActiveDirectory');
    }
}

# Synopsis: Consider configuring the minimum supported TLS version to be 1.2.
Rule 'Azure.SQL.MinTLS' -Ref 'AZR-000189' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $Assert.Version($TargetObject, 'Properties.minimalTlsVersion', '>=1.2');
}

# Synopsis: Azure SQL logical server names should meet naming requirements.
Rule 'Azure.SQL.ServerName' -Ref 'AZR-000190' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    # https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql

    # Between 1 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){0,62}$', $True);
}

#endregion SQL Logical Server

#region SQL Database

# Synopsis: Enable transparent data encryption
Rule 'Azure.SQL.TDE' -Ref 'AZR-000191' -Type 'Microsoft.Sql/servers/databases' -If { !(IsMasterDatabase) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/databases/transparentDataEncryption');
    if ($configs.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Sql/servers/databases/transparentDataEncryption');
    }
    foreach ($config in $configs) {
        if ($Assert.HasFieldValue($config, 'apiVersion', '2014-04-01').Result) {
            $Assert.HasFieldValue($config, 'Properties.status', 'Enabled');
        }
        else {
            $Assert.HasFieldValue($config, 'Properties.state', 'Enabled');
        }
    }
}

# Synopsis: Azure SQL Database names should meet naming requirements.
Rule 'Azure.SQL.DBName' -Ref 'AZR-000192' -Type 'Microsoft.Sql/servers/databases' -If { !(IsExport) } -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    # https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql

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
Rule 'Azure.SQL.FGName' -Ref 'AZR-000193' -Type 'Microsoft.Sql/servers/failoverGroups' -If { !(IsExport) } -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    # https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql

    $name = $PSRule.TargetName.Split('/')[-1];

    # Between 1 and 63 characters long
    $Assert.GreaterOrEqual($name, '.', 1);
    $Assert.LessOrEqual($name, '.', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($name, '.', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){0,62}$', $True);
}

#endregion Failover group

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

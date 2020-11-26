# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure SQL Database
#

#region SQL Logical Server

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.SQL.FirewallRuleCount' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/firewallRules');
    $Assert.
        LessOrEqual($firewallRules, '.', 10).
        WithReason(($LocalizedData.DBServerFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.SQL.AllowAzureAccess' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.Sql/servers/firewallRules' | Where-Object {
        $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.StartIpAddress -eq '0.0.0.0' -and $_.properties.EndIpAddress -eq '0.0.0.0')
    })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.SQL.FirewallIPRange' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $summary = GetIPAddressSummary
    $Assert.
        LessOrEqual($summary, 'Public', 10).
        WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True);
}

# Synopsis: Enable Advanced Thread Protection for Azure SQL logical server
Rule 'Azure.SQL.ThreatDetection' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $policy = GetSubResources -ResourceType 'Microsoft.Sql/servers/securityAlertPolicies'
    $policy | Within 'Properties.state' 'Enabled'
}

# Synopsis: Enable auditing for Azure SQL logical server
Rule 'Azure.SQL.Auditing' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $policy = GetSubResources -ResourceType 'Microsoft.Sql/servers/auditingSettings'
    $policy | Within 'Properties.state' 'Enabled'
}

# Synopsis: Use Azure AD administrators
Rule 'Azure.SQL.AAD' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $config = GetSubResources -ResourceType 'Microsoft.Sql/servers/administrators';
    $Assert.HasFieldValue($config, 'Properties.administratorType', 'ActiveDirectory');
}

# Synopsis: Consider configuring the minimum supported TLS version to be 1.2.
Rule 'Azure.SQL.MinTLS' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $Assert.Version($TargetObject, 'Properties.minimalTlsVersion', '>=1.2');
}

# Synopsis: Azure SQL logical server names should meet naming requirements.
Rule 'Azure.SQL.ServerName' -Type 'Microsoft.Sql/servers' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
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
Rule 'Azure.SQL.TDE' -Type 'Microsoft.Sql/servers/databases' -If { !(IsMasterDatabase) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $config = GetSubResources -ResourceType 'Microsoft.Sql/servers/databases/transparentDataEncryption';
    $Assert.HasFieldValue($config, 'Properties.status', 'Enabled');
}

# Synopsis: Azure SQL Database names should meet naming requirements.
Rule 'Azure.SQL.DBName' -Type 'Microsoft.Sql/servers/databases' -If { !(IsExport) } -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
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
Rule 'Azure.SQL.FGName' -Type 'Microsoft.Sql/servers/failoverGroups' -If { !(IsExport) } -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
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

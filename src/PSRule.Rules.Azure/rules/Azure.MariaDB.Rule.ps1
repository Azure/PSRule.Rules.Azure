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

# Synopsis: Enable Microsoft Defender for Cloud for Azure Database for MariaDB.
Rule 'Azure.MariaDB.DefenderCloud' -Ref 'AZR-000330' -Type 'Microsoft.DBforMariaDB/servers', 'Microsoft.DBforMariaDB/servers/securityAlertPolicies' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    if ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers') {
        $defenderConfigs = @(GetSubResources -ResourceType 'Microsoft.DBforMariaDB/servers/securityAlertPolicies')
        if ($defenderConfigs.Length -eq 0) {
            $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.DBforMariaDB/servers/securityAlertPolicies')
        }
        foreach ($defenderConfig in $defenderConfigs) {
            $Assert.HasFieldValue($defenderConfig, 'properties.state', 'Enabled').
            PathPrefix('resources')
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers/securityAlertPolicies') {
        $Assert.HasFieldValue($TargetObject, 'properties.state', 'Enabled')
    }
}

# Synopsis: Azure Database for MariaDB servers should only accept encrypted connections.
Rule 'Azure.MariaDB.UseSSL' -Ref 'AZR-000334' -Type 'Microsoft.DBforMariaDB/servers' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.sslEnforcement', 'Enabled').Reason($LocalizedData.MariaDBEncryptedConnection)
}

# Synopsis: Azure Database for MariaDB servers should reject TLS versions older than 1.2.
Rule 'Azure.MariaDB.MinTLS' -Ref 'AZR-000335' -Type 'Microsoft.DBforMariaDB/servers' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.minimalTlsVersion', 'TLS1_2')
}

# Synopsis: Azure Database for MariaDB servers should meet naming requirements.
Rule 'Azure.MariaDB.ServerName' -Ref 'AZR-000336' -Type 'Microsoft.DBforMariaDB/servers' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    # https://learn.microsoft.com/nb-no/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb

    # Between 3 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3)
    $Assert.LessOrEqual($PSRule, 'TargetName', 63)

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){2,62}$', $True)
}

# Synopsis: Azure Database for MariaDB databases should meet naming requirements.
Rule 'Azure.MariaDB.DatabaseName' -Ref 'AZR-000337' -Type 'Microsoft.DBforMariaDB/servers', 'Microsoft.DBforMariaDB/servers/databases' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    # https://learn.microsoft.com/nb-no/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb

    $databases = @(GetMariaDBDatabaseName)
    if ($databases.Length -eq 0) {
        $Assert.Pass()
    }

    foreach ($database in $databases) {
        # Between 1 and 63 characters long
        $Assert.GreaterOrEqual($database, '.', 1)
        $Assert.LessOrEqual($database, '.', 63)

        # Alphanumerics and hyphens
        $Assert.Match($database, '.', '^[A-Za-z0-9-]{1,63}$', $True)
    }
}

# Synopsis: Azure Database for MariaDB firewall rules should meet naming requirements.
Rule 'Azure.MariaDB.FirewallRuleName' -Ref 'AZR-000338' -Type 'Microsoft.DBforMariaDB/servers', 'Microsoft.DBforMariaDB/servers/firewallRules' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    # https://learn.microsoft.com/nb-no/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb

    $firewallRules = @(GetMariaDBFirewallRuleName)
    if ($firewallRules.Length -eq 0) {
        $Assert.Pass()
    }

    foreach ($firewallRule in $firewallRules) {
        # Between 1 and 128 characters long
        $Assert.GreaterOrEqual($firewallRule, '.', 1)
        $Assert.LessOrEqual($firewallRule, '.', 128)

        # Alphanumerics, hyphens and underscores
        $Assert.Match($firewallRule, '.', '^[A-Za-z0-9-_]{1,128}$', $True)
    }
}

# Synopsis: Azure Database for MariaDB VNET rules should meet naming requirements.
Rule 'Azure.MariaDB.VNETRuleName' -Ref 'AZR-000339' -Type 'Microsoft.DBforMariaDB/servers', 'Microsoft.DBforMariaDB/servers/virtualNetworkRules' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    # https://learn.microsoft.com/nb-no/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformariadb

    $virtualNetworkRules = @(GetMariaDBVNETRuleName)
    if ($virtualNetworkRules.Length -eq 0) {
        $Assert.Pass()
    }

    foreach ($virtualNetworkRule in $virtualNetworkRules) {
        # Between 1 and 128 characters long
        $Assert.GreaterOrEqual($virtualNetworkRule, '.', 1)
        $Assert.LessOrEqual($virtualNetworkRule, '.', 128)

        # Alphanumerics and hyphens
        $Assert.Match($virtualNetworkRule, '.', '^[A-Za-z0-9-]{1,128}$', $True)
    }
}

# Synopsis: Determine if access from Azure services is required.
Rule 'Azure.MariaDB.AllowAzureAccess' -Ref 'AZR-000342' -Type 'Microsoft.DBforMariaDB/servers', 'Microsoft.DBforMariaDB/servers/firewallRules' -Tag @{ release = 'GA'; ruleSet = '2022_12' } {
    $firewallAllowAzureServices = @(GetMariaDBFirewallRule |
        Where-Object { $_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0' })
    
    $Assert.Less($firewallAllowAzureServices, '.', 1).Reason($LocalizedData.MariaDBFirewallAllowAzureServices)
}

# Synopsis: Determine if there is an excessive number of firewall rules.
Rule 'Azure.MariaDB.FirewallRuleCount'-Ref 'AZR-000343' -Type 'Microsoft.DBforMariaDB/servers' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforMariaDB/servers/firewallRules')

    $Assert.LessOrEqual($firewallRules, '.', 10).
    Reason($LocalizedData.ExceededFirewallRuleCount, $firewallRules.Length, 10).PathPrefix('resources')
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses.
Rule 'Azure.MariaDB.FirewallIPRange' -Ref 'AZR-000344' -Type 'Microsoft.DBforMariaDB/servers' -Tag @{ release = 'GA'; ruleSet = '2022_12'; } {
    $summary = GetIPAddressSummary

    [int]$public = [int]$summary.Public
    $Assert.LessOrEqual($public, '.', 10).
    Reason($LocalizedData.DBServerFirewallPublicIPRange, $summary.Public, 10).PathPrefix('resources')
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

function global:GetMariaDBDatabaseName {
    [CmdletBinding()]
    [OutputType([string])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers') {
            GetSubResources -ResourceType 'Microsoft.DBforMariaDB/servers/databases' |
            ForEach-Object { ($_.name -split '/')[-1] }
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers/databases') {
            ($PSRule.TargetName -split '/')[-1]
        }
    }
}

function global:GetMariaDBFirewallRuleName {
    [CmdletBinding()]
    [OutputType([string])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers') {
            GetSubResources -ResourceType 'Microsoft.DBforMariaDB/servers/firewallRules' |
            ForEach-Object { $_.name }
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers/firewallRules') {
            $PSRule.TargetName
        }
    }
}

function global:GetMariaDBVNETRuleName {
    [CmdletBinding()]
    [OutputType([string])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers') {
            GetSubResources -ResourceType 'Microsoft.DBforMariaDB/servers/virtualNetworkRules' |
            ForEach-Object { $_.name }
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers/virtualNetworkRules') {
            $PSRule.TargetName
        }
    }
}

function global:GetMariaDBFirewallRule {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers') {
            GetSubResources -ResourceType 'Microsoft.DBforMariaDB/servers/firewallRules'
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.DBforMariaDB/servers/firewallRules') {
            $TargetObject
        }
    }
}

#endregion Helper functions

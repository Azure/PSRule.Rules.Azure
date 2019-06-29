#
# Validation rules for Azure SQL Database
#

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.SQL.FirewallRuleCount' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Awareness'; category = 'Operations management' } {
    Hint 'SQL Server has > 10 firewall rules, some rules may not be needed';

    $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.Sql/servers/firewallRules'
    })
    $firewallRules.Length -le 10;
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.SQL.AllowAzureAccess' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.Sql/servers/firewallRules' -and
        (
            $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
            ($_.properties.StartIpAddress -eq '0.0.0.0' -and $_.properties.EndIpAddress -eq '0.0.0.0')
        )
    })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.SQL.FirewallIPRange' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $summary = GetIPAddressSummary
    $summary.Public -le 10;
}

# Synopsis: Enable threat detection for Azure SQL logical server
Rule 'Azure.SQL.ThreatDetection' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $threatPolicy = $TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.Sql/servers/securityAlertPolicies'
    }
    $Null -ne $threatPolicy;
    if ($Null -ne $threatPolicy) {
        $threatPolicy.ThreatDetectionState -eq 0 # 0 = Enabled, 1 = Disabled
    }
}

# Synopsis: Enable auditing for Azure SQL logical server
Rule 'Azure.SQL.Auditing' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $auditPolicy = $TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.Sql/servers/auditingSettings'
    }
    $Null -ne $auditPolicy;
    if ($Null -ne $auditPolicy) {
        $auditPolicy.AuditState -eq 0 # 0 = Enabled, 1 = Disabled
    }
}

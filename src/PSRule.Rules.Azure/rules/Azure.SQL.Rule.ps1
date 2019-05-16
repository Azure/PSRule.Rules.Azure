#
# Validation rules for Azure SQL Database
#

# Description: Determine if there is an excessive number of firewall rules
Rule 'Azure.SQL.FirewallRuleCount' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Awareness'; category = 'Operations management' } {
    Hint 'SQL Server has <= 5 firewall rules, some rules may not be needed';

    $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.Sql/servers/firewallRules'
    })
    $firewallRules.Length -le 5;
}

# Description: Determine if access from Azure servers is required
Rule 'Azure.SQL.AllowAzureAccess' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.Sql/servers/firewallRules' -and
        (
            $_.FirewallRuleName -eq 'AllowAllWindowsAzureIps' -or
            ($_.StartIpAddress -eq '0.0.0.0' -and $_.EndIpAddress -eq '0.0.0.0')
        )
    })
    $firewallRules.Length -eq 0;
}

# Description: Enable threat detection for Azure SQL logical server
Rule 'Azure.SQL.ThreatDetection' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $threatPolicy = $TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.Sql/servers/securityAlertPolicies'
    }
    $Null -ne $threatPolicy;
    if ($Null -ne $threatPolicy) {
        $threatPolicy.ThreatDetectionState -eq 0 # 0 = Enabled, 1 = Disabled
    }
}

# Description: Enable auditing for Azure SQL logical server
Rule 'Azure.SQL.Auditing' -If { ResourceType 'Microsoft.Sql/servers' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $auditPolicy = $TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.Sql/servers/auditingSettings'
    }
    $Null -ne $auditPolicy;
    if ($Null -ne $auditPolicy) {
        $auditPolicy.AuditState -eq 0 # 0 = Enabled, 1 = Disabled
    }
}

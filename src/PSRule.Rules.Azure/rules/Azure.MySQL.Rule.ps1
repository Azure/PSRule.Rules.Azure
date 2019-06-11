#
# Validation rules for Azure Database for MySQL
#

# Synopsis: Use encrypted MySQL connections
Rule 'Azure.MySQL.UseSSL' -If { ResourceType 'Microsoft.DBforMySQL/servers' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.sslEnforcement' 'Enabled'
}

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.MySQL.FirewallRuleCount' -If { ResourceType 'Microsoft.DBforMySQL/servers' } -Tag @{ severity = 'Awareness'; category = 'Operations management' } {
    Hint 'SQL Server has > 10 firewall rules, some rules may not be needed';

    $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.DBforMySQL/servers/firewallRules'
    })
    $firewallRules.Length -le 10;
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.MySQL.AllowAzureAccess' -If { ResourceType 'Microsoft.DBforMySQL/servers' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.DBforMySQL/servers/firewallRules' -and
        (
            $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
            ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0')
        )
    })
    $firewallRules.Length -eq 0;
}

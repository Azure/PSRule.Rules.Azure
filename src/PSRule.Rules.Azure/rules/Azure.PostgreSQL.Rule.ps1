#
# Validation rules for Azure Database for PostgreSQL
#

# Synopsis: Use encrypted PostgreSQL connections
Rule 'Azure.PostgreSQL.UseSSL' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.sslEnforcement' 'Enabled'
}

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.PostgreSQL.FirewallRuleCount' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; severity = 'Awareness'; category = 'Operations management' } {
    Recommend 'PostgreSQL Server has > 10 firewall rules, some rules may not be needed';

    $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.DBforPostgreSQL/servers/firewallRules'
    })
    $firewallRules.Length -le 10;
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.PostgreSQL.AllowAzureAccess' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; severity = 'Important'; category = 'Security configuration' } {
    $firewallRules = @($TargetObject.resources | Where-Object -FilterScript {
        $_.Type -eq 'Microsoft.DBforPostgreSQL/servers/firewallRules' -and
        (
            $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
            ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0')
        )
    })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.PostgreSQL.FirewallIPRange' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; severity = 'Important'; category = 'Security configuration' } {
    $summary = GetIPAddressSummary
    $summary.Public -le 10;
}

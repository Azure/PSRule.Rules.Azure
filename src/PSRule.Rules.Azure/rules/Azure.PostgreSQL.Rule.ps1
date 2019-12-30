#
# Validation rules for Azure Database for PostgreSQL
#

# Synopsis: Use encrypted PostgreSQL connections
Rule 'Azure.PostgreSQL.UseSSL' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.sslEnforcement', 'Enabled')
}

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.PostgreSQL.FirewallRuleCount' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA' } {
    $firewallRules = GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules'
    $firewallRules.Length -le 10;
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.PostgreSQL.AllowAzureAccess' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules' | Where-Object {
        $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0')
    })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.PostgreSQL.FirewallIPRange' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA' } {
    $summary = GetIPAddressSummary
    $summary.Public -le 10;
}

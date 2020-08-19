# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Database for PostgreSQL
#

# Synopsis: Use encrypted PostgreSQL connections
Rule 'Azure.PostgreSQL.UseSSL' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.sslEnforcement', 'Enabled');
}

# Synopsis: Consider configuring the minimum supported TLS version to be 1.2.
Rule 'Azure.PostgreSQL.MinTLS' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.minimalTlsVersion', 'TLS1_2');
}

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.PostgreSQL.FirewallRuleCount' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules');
    $Assert.
        LessOrEqual($firewallRules, '.', 10).
        WithReason(($LocalizedData.DBServerFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.PostgreSQL.AllowAzureAccess' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforPostgreSQL/servers/firewallRules' | Where-Object {
        $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0')
    })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.PostgreSQL.FirewallIPRange' -Type 'Microsoft.DBforPostgreSQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $summary = GetIPAddressSummary
    $Assert.
        LessOrEqual($summary, 'Public', 10).
        WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True);
}

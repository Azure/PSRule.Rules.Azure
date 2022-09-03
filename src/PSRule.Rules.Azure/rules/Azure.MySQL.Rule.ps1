# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Database for MySQL
#

# Synopsis: Determine if there is an excessive number of firewall rules
Rule 'Azure.MySQL.FirewallRuleCount' -Ref 'AZR-000133' -Type 'Microsoft.DBforMySQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforMySQL/servers/firewallRules');
    $Assert.
        LessOrEqual($firewallRules, '.', 10).
        WithReason(($LocalizedData.DBServerFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if access from Azure services is required
Rule 'Azure.MySQL.AllowAzureAccess' -Ref 'AZR-000134' -Type 'Microsoft.DBforMySQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DBforMySQL/servers/firewallRules' | Where-Object {
        $_.ResourceName -eq 'AllowAllWindowsAzureIps' -or
        ($_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0')
    })
    $firewallRules.Length -eq 0;
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses
Rule 'Azure.MySQL.FirewallIPRange' -Ref 'AZR-000135' -Type 'Microsoft.DBforMySQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $summary = GetIPAddressSummary
    $Assert.
        LessOrEqual($summary, 'Public', 10).
        WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True);
}

# Synopsis: Azure SQL logical server names should meet naming requirements.
Rule 'Azure.MySQL.ServerName' -Ref 'AZR-000136' -Type 'Microsoft.DBforMySQL/servers' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    # https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftdbformysql

    # Between 3 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){2,62}$', $True);
}

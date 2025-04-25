# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Network Security Groups (NSGs)
#

#region Rules

# Synopsis: Network security groups should avoid any inbound rules
Rule 'Azure.NSG.AnyInboundSource' -Ref 'AZR-000137' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $inboundRules = @(GetOrderedNSGRules -Direction Inbound);
    $rules = $inboundRules | Where-Object {
        $_.properties.access -eq 'Allow' -and
        $_.properties.sourceAddressPrefix -eq '*'
    }
    $Null -eq $rules;
}

# Synopsis: Avoid blocking all inbound network traffic
Rule 'Azure.NSG.DenyAllInbound' -Ref 'AZR-000138' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    Reason $LocalizedData.AllInboundRestricted;
    $inboundRules = @(GetOrderedNSGRules -Direction Inbound);
    $denyRules = @($inboundRules | Where-Object {
        $_.properties.access -eq 'Deny' -and
        $_.properties.sourceAddressPrefix -eq '*'
    })
    $Null -eq $denyRules -or $denyRules.Length -eq 0 -or $denyRules[0].name -ne $inboundRules[0].name
}

# Synopsis: Lateral traversal from application servers should be blocked
Rule 'Azure.NSG.LateralTraversal' -Ref 'AZR-000139' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $nsg = [PSRule.Rules.Azure.Runtime.Helper]::GetNetworkSecurityGroup(@(GetOrderedNSGRules -Direction Outbound));

    $rdp = $nsg.Outbound('VirtualNetwork', 3389);
    $ssh = $nsg.Outbound('VirtualNetwork', 22);

    if (($rdp -eq 'Allow' -or $rdp -eq 'Default') -and ($ssh -eq 'Allow' -or $ssh -eq 'Default')) {
        return $Assert.Fail($LocalizedData.LateralTraversalNotRestricted);
    }
    return $Assert.Pass();
}

# Synopsis: Network security groups should be associated to either a subnet or network interface
Rule 'Azure.NSG.Associated' -Ref 'AZR-000140' -Type 'Microsoft.Network/networkSecurityGroups' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    # NSG should be associated to either a subnet or network interface
    Reason $LocalizedData.ResourceNotAssociated
    $Assert.HasFieldValue($TargetObject, 'Properties.subnets').Result -or
        $Assert.HasFieldValue($TargetObject, 'Properties.networkInterfaces').Result
}

# Synopsis: Use standard network security group names.
Rule 'Azure.NSG.Naming' -Ref 'AZR-000467' -Type 'Microsoft.Network/networkSecurityGroups' -If { $Configuration['AZURE_NETWORK_SECURITY_GROUP_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_NETWORK_SECURITY_GROUP_NAME_FORMAT, $True);
}

#endregion Rules

#region Helper functions

# Get a sorted list of NSG rules
function global:GetOrderedNSGRules {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $True)]
        [ValidateSet('Inbound', 'Outbound')]
        [String]$Direction
    )
    process {
        $TargetObject.properties.securityRules |
            Where-Object { $_.properties.direction -eq $Direction } |
            Sort-Object @{ Expression = { $_.Properties.priority }; Descending = $False }
    }
}

#endregion Helper functions

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for virtual networking
#

#region Virtual Network

# Synopsis: Virtual network (VNET) subnets should have Network Security Groups (NSGs) assigned.
Rule 'Azure.VNET.UseNSGs' -Ref 'AZR-000263' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; 'Azure.ASB.v3/control' = 'NS-1' } {
    $excludedSubnets = @('GatewaySubnet', 'AzureFirewallSubnet', 'AzureFirewallManagementSubnet', 'RouteServerSubnet');
    $subnet = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        # Get subnets
        $subnet = @($TargetObject.properties.subnets | Where-Object {
                $_.Name -notin $excludedSubnets -and @($_.properties.delegations | Where-Object { $_.properties.serviceName -eq 'Microsoft.HardwareSecurityModules/dedicatedHSMs' }).Length -eq 0
            });
        if ($subnet.Length -eq 0 -or !$Assert.HasFieldValue($TargetObject, 'properties.subnets').Result) {
            return $Assert.Pass();
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks/subnets' -and
    ($PSRule.TargetName -in $excludedSubnets -or @($TargetObject.properties.delegations | Where-Object { $_.properties.serviceName -eq 'Microsoft.HardwareSecurityModules/dedicatedHSMs' }).Length -gt 0)) {
        return $Assert.Pass();
    }
    foreach ($sn in $subnet) {
        $Assert.
        HasFieldValue($sn, 'properties.networkSecurityGroup.id').
        WithReason(($LocalizedData.SubnetNSGNotConfigured -f $sn.Name), $True);
    }
}

# TODO: Check that NSG on GatewaySubnet is not defined

# Synopsis: VNETs should have at least two DNS servers assigned
Rule 'Azure.VNET.SingleDNS' -Ref 'AZR-000264' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # If DNS servers are customized, at least two IP addresses should be defined
    if ($Assert.NullOrEmpty($TargetObject, 'properties.dhcpOptions.dnsServers').Result) {
        $True;
    }
    else {
        $Assert.GreaterOrEqual($TargetObject, 'properties.dhcpOptions.dnsServers', 2);
    }
}

# Synopsis: VNETs should use Azure local DNS servers
Rule 'Azure.VNET.LocalDNS' -Ref 'AZR-000265' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # If DNS servers are customized, check what range the IPs are in
    if ($Assert.NullOrEmpty($TargetObject, 'properties.dhcpOptions.dnsServers').Result) {
        $True;
    }
    else {
        # Primary DNS server must be within VNET address space or peered VNET
        $dnsServers = @($TargetObject.Properties.dhcpOptions.dnsServers)
        $primary = $dnsServers[0]
        $localRanges = @();
        $localRanges += $TargetObject.Properties.addressSpace.addressPrefixes
        if ($Assert.HasFieldValue($TargetObject, 'Properties.virtualNetworkPeerings').Result) {
            $localRanges += $TargetObject.Properties.virtualNetworkPeerings.properties.remoteAddressSpace.addressPrefixes
        }

        # Determine if the primary is in range
        WithinCIDR -IP $primary -CIDR $localRanges
    }
}

# Synopsis: VNET peers should be connected
Rule 'Azure.VNET.PeerState' -Ref 'AZR-000266' -If { (HasPeerNetwork) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $peers = @($TargetObject.Properties.virtualNetworkPeerings);
    foreach ($peer in $peers) {
        $Assert.HasFieldValue($peer, 'Properties.peeringState', 'Connected');
    }
}

# Synopsis: Use subnets naming requirements
Rule 'Azure.VNET.SubnetName' -Ref 'AZR-000267' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        $subnets = @($TargetObject.Properties.subnets)
        if ($subnets.Length -eq 0 -or !$Assert.HasFieldValue($TargetObject, 'properties.subnets').Result) {
            $Assert.Pass();
        }
        else {
            foreach ($subnet in $subnets) {
                # Between 1 and 80 characters long
                $Assert.GreaterOrEqual($subnet, 'Name', 1)
                $Assert.LessOrEqual($subnet, 'Name', 80)
    
                # Alphanumerics, underscores, periods, and hyphens.
                # Start with alphanumeric. End alphanumeric or underscore.
                $subnet | Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
            }
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks/subnets') {
        $nameParts = $PSRule.TargetName.Split('/');
        $name = $nameParts[-1];

        # Between 1 and 80 characters long
        $Assert.GreaterOrEqual($name, '.', 1)
        $Assert.LessOrEqual($name, '.', 80)

        # Alphanumerics, underscores, periods, and hyphens.
        # Start with alphanumeric. End alphanumeric or underscore.
        $name | Match '.' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
    }
}

# Synopsis: VNETs with a GatewaySubnet should have an AzureBastionSubnet to allow for out of band remote access to VMs.
Rule 'Azure.VNET.BastionSubnet' -Ref 'AZR-000314' -Type 'Microsoft.Network/virtualNetworks' -If { HasGatewaySubnet } -Tag @{ release = 'GA'; ruleSet = '2022_12' } {
    $subnets = @(GetVirtualNetworkSubnets)
    $Assert.In($subnets, '.', @('AzureBastionSubnet')).Reason($LocalizedData.BastionSubnetNotFound, $PSRule.TargetName)
}

#endregion Virtual Network

#region Helper functions

function global:HasGatewaySubnet {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        ($TargetObject.Properties.subnets | Where-Object { $_.name -eq 'GatewaySubnet' }) -or
        (@(GetSubResources -ResourceType 'Microsoft.Network/virtualNetworks/subnets' |
            Where-Object { $_.name -eq 'GatewaySubnet' }))
    }
}

function global:GetVirtualNetworkSubnets {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param ()
    process {
        $TargetObject.Properties.subnets | ForEach-Object { $_.name }
        GetSubResources -ResourceType 'Microsoft.Network/virtualNetworks/subnets' | ForEach-Object { $_.name }
    }
}

#endregion Helper functions

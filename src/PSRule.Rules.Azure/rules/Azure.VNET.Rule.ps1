# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for virtual networking
#

#region Virtual Network

# Synopsis: Virtual network (VNET) subnets should have Network Security Groups (NSGs) assigned.
Rule 'Azure.VNET.UseNSGs' -Ref 'AZR-000263' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'NS-1' } {
    $excludedSubnets = @('GatewaySubnet', 'AzureFirewallSubnet', 'AzureFirewallManagementSubnet', 'RouteServerSubnet');
    foreach ($exclusion in $Configuration.GetStringValues('AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG')) {
        if ($exclusion) {
            $excludedSubnets += $exclusion;
        }
    }

    function IsHSM($subnetObject) {
        return @($subnetObject.properties.delegations | Where-Object { $_.properties.serviceName -eq 'Microsoft.HardwareSecurityModules/dedicatedHSMs' }).Length -gt 0;
    }

    function IsExcludedSubnet($subnetName) {
        return [PSRule.Rules.Azure.Runtime.Helper]::GetSubResourceName($subnetName) -in $excludedSubnets;
    }

    $subnet = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        $subnet = @(GetVirtualNetworkSubnets | Where-Object { $null -ne $_ });
    }

    if ($subnet.Length -eq 0) {
        return $Assert.Pass();
    }

    foreach ($sn in $subnet) {
        if ((IsExcludedSubnet($sn.Name)) -or (IsHSM($sn))) {
            $Assert.Pass();
            continue;
        }

        $Assert.
        HasFieldValue($sn, 'properties.networkSecurityGroup.id').
        WithReason(($LocalizedData.SubnetNSGNotConfigured -f $sn.Name), $True);
    }
}

# Synopsis: VNETs should have at least two DNS servers assigned.
Rule 'Azure.VNET.SingleDNS' -Ref 'AZR-000264' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    # If DNS servers are customized, at least two IP addresses should be defined
    if ($Assert.NullOrEmpty($TargetObject, 'properties.dhcpOptions.dnsServers').Result) {
        $Assert.Pass()
    }
    else {
        $Assert.GreaterOrEqual($TargetObject, 'properties.dhcpOptions.dnsServers', 2);
    }
}

# Synopsis: Virtual networks (VNETs) should use Azure local DNS servers.
Rule 'Azure.VNET.LocalDNS' -Ref 'AZR-000265' -Type 'Microsoft.Network/virtualNetworks' -If { (IsExport) -and !($Configuration.GetBoolOrDefault('AZURE_VNET_DNS_WITH_IDENTITY', $False)) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    # If DNS servers are customized, check what range the IPs are in
    if ($Assert.NullOrEmpty($TargetObject, 'properties.dhcpOptions.dnsServers').Result) {
        $Assert.Pass()
    }
    else {
        # Primary DNS server must be within VNET address space or peered VNET
        $dnsServers = @($TargetObject.properties.dhcpOptions.dnsServers)
        $primary = $dnsServers[0]
        $localRanges = @();
        $localRanges += $TargetObject.properties.addressSpace.addressPrefixes
        if ($Assert.HasFieldValue($TargetObject, 'properties.virtualNetworkPeerings').Result) {
            $localRanges += $TargetObject.properties.virtualNetworkPeerings.properties.remoteAddressSpace.addressPrefixes
        }

        # Determine if the primary is in range
        WithinCIDR -IP $primary -CIDR $localRanges
    }
}

# Synopsis: VNET peering connections must be connected.
Rule 'Azure.VNET.PeerState' -Ref 'AZR-000266' -If { (HasPeerNetwork) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $peers = @($TargetObject.properties.virtualNetworkPeerings);
    foreach ($peer in $peers) {
        $Assert.HasFieldValue($peer, 'Properties.peeringState', 'Connected');
    }
}

# Synopsis: Subnet names should meet naming requirements.
Rule 'Azure.VNET.SubnetName' -Ref 'AZR-000267' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } -Labels @{ 'Azure.CAF' = 'naming' } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        $subnets = @($TargetObject.properties.subnets)
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
Rule 'Azure.VNET.BastionSubnet' -Ref 'AZR-000314' -Type 'Microsoft.Network/virtualNetworks' -If { HasGatewaySubnet } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $subnets = @(GetVirtualNetworkSubnetNames)
    $Assert.In($subnets, '.', @('AzureBastionSubnet')).ReasonFrom('properties.subnets', $LocalizedData.SubnetNotFound, 'AzureBastionSubnet')
}

# Synopsis: Use Azure Firewall to filter network traffic to and from Azure resources.
Rule 'Azure.VNET.FirewallSubnet' -Ref 'AZR-000322' -Type 'Microsoft.Network/virtualNetworks' -If { HasGatewaySubnet } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    $subnets = @(GetVirtualNetworkSubnetNames)
    $Assert.In($subnets, '.', @('AzureFirewallSubnet')).ReasonFrom('properties.subnets', $LocalizedData.SubnetNotFound, 'AzureFirewallSubnet')
}

# Synopsis: Zonal-deployed Azure Firewalls should consider using an Azure NAT Gateway for outbound access.
Rule 'Azure.VNET.FirewallSubnetNAT' -Ref 'AZR-000448' -Level 'Warning' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -If { $Configuration.GetBoolOrDefault('AZURE_FIREWALL_IS_ZONAL', $False) } -Tag @{ release = 'GA'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        $subnets = @(
            $TargetObject.properties.subnets | Where-Object { $null -ne $_ -and ($_.name -eq 'AzureFirewallSubnet' -or $_.name -like '*/AzureFirewallSubnet') }
            GetSubResources -ResourceType 'Microsoft.Network/virtualNetworks/subnets' | Where-Object { $null -ne $_ -and ($_.name -eq 'AzureFirewallSubnet' -or $_.name -like '*/AzureFirewallSubnet') }
        )
    }

    else {
        $subnets = @($TargetObject | Where-Object { $_.name -eq 'AzureFirewallSubnet' -or $_.name -like '*/AzureFirewallSubnet' })
    }

    if ($subnets.Count -eq 0) {
        return $Assert.Pass()
    }

    foreach ($subnet in $subnets) {
        $Assert.HasFieldValue($subnet, 'properties.natGateway.id').Reason($LocalizedData.FirewallSubnetNAT)
    }
}

# Synopsis: Disable default outbound access for virtual machines.
Rule 'Azure.VNET.PrivateSubnet' -Ref 'AZR-000447' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $excludedSubnets = @('GatewaySubnet', 'AzureFirewallSubnet', 'AzureFirewallManagementSubnet', 'AzureBastionSubnet')
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        $subnets = @(
            $TargetObject.properties.subnets | Where-Object { $null -ne $_ -and -not $_.properties.delegations -and [PSRule.Rules.Azure.Runtime.Helper]::GetSubResourceName($_.name) -notin $excludedSubnets }
            GetSubResources -ResourceType 'Microsoft.Network/virtualNetworks/subnets' | Where-Object { $null -ne $_ -and -not $_.properties.delegations -and [PSRule.Rules.Azure.Runtime.Helper]::GetSubResourceName($_.name) -notin $excludedSubnets }
        )
    }

    else {
        $subnets = @($TargetObject | Where-Object { -not $_.properties.delegations -and [PSRule.Rules.Azure.Runtime.Helper]::GetSubResourceName($_.name) -notin $excludedSubnets } )
    }

    if ($subnets.Count -eq 0) {
        return $Assert.Pass()
    }

    foreach ($subnet in $subnets) {
        $Assert.HasFieldValue($subnet, 'properties.defaultOutboundAccess', $false).Reason($LocalizedData.PrivateSubnet, $subnet.name)
    }
}

# Synopsis: Use standard virtual networks names.
Rule 'Azure.VNET.Naming' -Ref 'AZR-000474' -Type 'Microsoft.Network/virtualNetworks' -If { $Configuration['AZURE_VNET_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_VNET_NAME_FORMAT, $True);
}

# Synopsis: Use standard subnets names.
Rule 'Azure.VNET.SubnetNaming' -Ref 'AZR-000475' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -If { $Configuration['AZURE_VNET_SUBNET_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $excludedSubnets = @('GatewaySubnet', 'AzureBastionSubnet', 'AzureFirewallSubnet', 'AzureFirewallManagementSubnet', 'RouteServerSubnet');

    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        $subnets = @(GetVirtualNetworkSubnets | Where-Object { $null -ne $_ });

        if ($subnets.Length -eq 0) {
            $Assert.Pass();
        }
        foreach ($subnet in $subnets) {
            $name = [PSRule.Rules.Azure.Runtime.Helper]::GetSubResourceName($subnet.Name);

            if ($name -in $excludedSubnets) {
                $Assert.Pass();
            }
            else {
                $Assert.Match($name, '.', $Configuration.AZURE_VNET_SUBNET_NAME_FORMAT, $True);
            }
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks/subnets') {
        $name = [PSRule.Rules.Azure.Runtime.Helper]::GetSubResourceName($PSRule.TargetName);

        if ($name -in $excludedSubnets) {
            $Assert.Pass();
        }
        else {
            $Assert.Match($name, '.', $Configuration.AZURE_VNET_SUBNET_NAME_FORMAT, $True);
        }
    }
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

function global:GetVirtualNetworkSubnetNames {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param ()
    process {
        $TargetObject.Properties.subnets | ForEach-Object { $_.name }
        GetSubResources -ResourceType 'Microsoft.Network/virtualNetworks/subnets', 'subnets' | ForEach-Object { $_.name }
    }
}


function global:GetVirtualNetworkSubnets {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param ()
    process {
        $TargetObject.Properties.subnets
        GetSubResources -ResourceType 'Microsoft.Network/virtualNetworks/subnets', 'subnets'
    }
}

#endregion Helper functions

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for virtual networking
#

#region Virtual Network

# Synopsis: Virtual network (VNET) subnets should have Network Security Groups (NSGs) assigned.
Rule 'Azure.VNET.UseNSGs' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $subnet = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        # Get subnets
        $subnet = @($TargetObject.properties.subnets | Where-Object { $_.Name -notin 'GatewaySubnet', 'AzureFirewallSubnet', 'AzureFirewallManagementSubnet' });
        if ($subnet.Length -eq 0) {
            return $Assert.Pass();
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks/subnets' -and $PSRule.TargetName -in 'GatewaySubnet', 'AzureFirewallSubnet', 'AzureFirewallManagementSubnet') {
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
Rule 'Azure.VNET.SingleDNS' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # If DNS servers are customized, at least two IP addresses should be defined
    if ($Assert.NullOrEmpty($TargetObject, 'properties.dhcpOptions.dnsServers').Result) {
        $True;
    }
    else {
        $Assert.GreaterOrEqual($TargetObject, 'properties.dhcpOptions.dnsServers', 2);
    }
}

# Synopsis: VNETs should use Azure local DNS servers
Rule 'Azure.VNET.LocalDNS' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
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
Rule 'Azure.VNET.PeerState' -If { (HasPeerNetwork) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $peers = @($TargetObject.Properties.virtualNetworkPeerings);
    foreach ($peer in $peers) {
        $Assert.HasFieldValue($peer, 'Properties.peeringState', 'Connected');
    }
}

# Synopsis: Use VNET naming requirements
Rule 'Azure.VNET.Name' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 2 and 64 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 2)
    $Assert.LessOrEqual($TargetObject, 'Name', 64)

    # Alphanumerics, underscores, periods, and hyphens.
    # Start with alphanumeric. End alphanumeric or underscore.
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){1,63}$'
}

# Synopsis: Use subnets naming requirements
Rule 'Azure.VNET.SubnetName' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        $subnets = @($TargetObject.Properties.subnets)
        if ($subnets.Length -eq 0) {
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

#endregion Virtual Network

#region Route tables

# Synopsis: Use route table naming requirements
Rule 'Azure.Route.Name' -Type 'Microsoft.Network/routeTables' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens.
    # Start with alphanumeric. End alphanumeric or underscore.
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

#endregion Route tables

#region Network Security Group

# Synopsis: Network security groups should avoid any inbound rules
Rule 'Azure.NSG.AnyInboundSource' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $inboundRules = @(GetOrderedNSGRules -Direction Inbound);
    $rules = $inboundRules | Where-Object {
        $_.properties.access -eq 'Allow' -and
        $_.properties.sourceAddressPrefix -eq '*'
    }
    $Null -eq $rules;
}

# Synopsis: Avoid blocking all inbound network traffic
Rule 'Azure.NSG.DenyAllInbound' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Reason $LocalizedData.AllInboundRestricted;
    $inboundRules = @(GetOrderedNSGRules -Direction Inbound);
    $denyRules = @($inboundRules | Where-Object {
        $_.properties.access -eq 'Deny' -and
        $_.properties.sourceAddressPrefix -eq '*'
    })
    $Null -eq $denyRules -or $denyRules.Length -eq 0 -or $denyRules[0].name -ne $inboundRules[0].name
}

# Synopsis: Lateral traversal from application servers should be blocked
Rule 'Azure.NSG.LateralTraversal' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $nsg = [PSRule.Rules.Azure.Runtime.Helper]::GetNetworkSecurityGroup(@(GetOrderedNSGRules -Direction Outbound));

    $rdp = $nsg.Outbound('VirtualNetwork', 3389);
    $ssh = $nsg.Outbound('VirtualNetwork', 22);

    if (($rdp -eq 'Allow' -or $rdp -eq 'Default') -and ($ssh -eq 'Allow' -or $ssh -eq 'Default')) {
        return $Assert.Fail($LocalizedData.LateralTraversalNotRestricted);
    }
    return $Assert.Pass();
}

# Synopsis: Network security groups should be associated to either a subnet or network interface
Rule 'Azure.NSG.Associated' -Type 'Microsoft.Network/networkSecurityGroups' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # NSG should be associated to either a subnet or network interface
    Reason $LocalizedData.ResourceNotAssociated
    $Assert.HasFieldValue($TargetObject, 'Properties.subnets').Result -or
        $Assert.HasFieldValue($TargetObject, 'Properties.networkInterfaces').Result
}

# Synopsis: Use network security group naming requirements
Rule 'Azure.NSG.Name' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens.
    # Start with alphanumeric. End alphanumeric or underscore.
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

#endregion Network Security Group

#region Load Balancer

# Synopsis: Use specific network probe
Rule 'Azure.LB.Probe' -Type 'Microsoft.Network/loadBalancers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $probes = $TargetObject.Properties.probes;
    foreach ($probe in $probes) {
        if ($probe.properties.port -in 80, 443, 8080) {
            if ($probe.properties.protocol -in 'Http', 'Https') {
                $Assert.Create(($probe.properties.requestPath -ne '/'), ($LocalizedData.RootHttpProbePath -f $probe.name, $probe.properties.requestPath))
            }
            else {
                $Assert.Create($False, ($LocalizedData.TcpHealthProbe -f $probe.name))
            }
        }
        else {
            $True;
        }
    }
}

# Synopsis: Use load balancer naming requirements
Rule 'Azure.LB.Name' -Type 'Microsoft.Network/loadBalancers' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens.
    # Start with alphanumeric. End alphanumeric or underscore.
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

# Synopsis: Load balancers deployed with Standard SKU should be zone-redundant for high availability.
Rule 'Azure.LB.AvailabilityZone' -Type 'Microsoft.Network/loadBalancers' -If { (IsStandardLoadBalancer).Result } -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    foreach ($ipConfig in $TargetObject.Properties.frontendIPConfigurations) {
        $zonesNotSet = $Assert.NullOrEmpty($ipConfig, 'zones').Result;

        $zoneRedundant = -not ($ipConfig.zones -and (Compare-Object -ReferenceObject @('1','2','3') -DifferenceObject $ipConfig.zones));

        $Assert.Create(
            ($zonesNotSet -or $zoneRedundant), 
            $LocalizedData.LBAvailabilityZone, 
            $TargetObject.name, 
            $ipConfig.name
        );
    }
}

# Synopsis: Load balancers should be deployed with Standard SKU for production workloads.
Rule 'Azure.LB.StandardSKU' -Type 'Microsoft.Network/loadBalancers' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    IsStandardLoadBalancer;
}

#endregion Load Balancer

#region Azure Firewall

# Synopsis: Threat intelligence denies high confidence malicious IP addresses and domains
Rule 'Azure.Firewall.Mode' -Type 'Microsoft.Network/azureFirewalls' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.threatIntelMode', 'Deny');
}

#endregion Azure Firewall

#region Virtual Network Gateway

# Synopsis: Migrate from legacy VPN gateway SKUs
Rule 'Azure.VNG.VPNLegacySKU' -Type 'Microsoft.Network/virtualNetworkGateways' -If { IsVPNGateway } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Within 'Properties.sku.name' -Not 'Basic', 'Standard', 'HighPerformance';
}

# Synopsis: Use Active-Active configuration
Rule 'Azure.VNG.VPNActiveActive' -Type 'Microsoft.Network/virtualNetworkGateways' -If { IsVPNGateway } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.activeActive', $True);
}

# Synopsis: Migrate from legacy ExpressRoute gateway SKUs
Rule 'Azure.VNG.ERLegacySKU' -Type 'Microsoft.Network/virtualNetworkGateways' -If { IsERGateway } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Within 'Properties.sku.name' -Not 'Basic';
}

# Synopsis: Use virtual network gateway naming requirements
Rule 'Azure.VNG.Name' -Type 'Microsoft.Network/virtualNetworkGateways' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens.
    # Start with alphanumeric. End alphanumeric or underscore.
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

# Synopsis: Use virtual networks gateway connection naming requirements
Rule 'Azure.VNG.ConnectionName' -Type 'Microsoft.Network/connections' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens.
    # Start with alphanumeric. End alphanumeric or underscore.
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

#endregion Virtual Network Gateway

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

function global:IsVPNGateway {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return $Assert.HasFieldValue($TargetObject, 'Properties.gatewayType', 'Vpn').Result;
    }
}

function global:IsERGateway {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return $Assert.HasFieldValue($TargetObject, 'Properties.gatewayType', 'ExpressRoute').Result;
    }
}

function global:IsStandardLoadBalancer {
    [CmdletBinding()]
    [OutputType([PSRule.Runtime.AssertResult])]
    param ()
    process {
        return $Assert.HasFieldValue($TargetObject, 'sku.name', 'Standard');
    }
}

#endregion Helper functions

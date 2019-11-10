#
# Validation rules for virtual networking
#

#region Virtual Network

# Synopsis: Subnets should have NSGs assigned, except for the GatewaySubnet
Rule 'Azure.VirtualNetwork.UseNSGs' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Recommend 'Subnets should have NSGs assigned'

    # Get subnets
    $subnets = $TargetObject.properties.subnets | Where-Object { $_.Name -ne 'GatewaySubnet' };

    if ($Null -ne $subnets) {
        $withNSGCount = ($subnets | Where-Object { $Null -ne $_.properties.networkSecurityGroup.id } | Measure-Object).Count

        # Are there subnets without NSGs configured
        return $withNSGCount -eq $subnets.Count
    }
}

# TODO: Check that NSG on GatewaySubnet is not defined

# Synopsis: VNETs should have at least two DNS servers assigned
Rule 'Azure.VirtualNetwork.SingleDNS' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ severity = 'Single point of failure'; category = 'Reliability' } {
    # If DNS servers are customized, at least two IP addresses should be defined
    if ($Assert.NullOrEmpty($TargetObject, 'properties.dhcpOptions.dnsServers').Result) {
        $True;
    }
    else {
        $TargetObject.properties.dhcpOptions.dnsServers.Count -ge 2;
    }
}

# Synopsis: VNETs should use Azure local DNS servers
Rule 'Azure.VirtualNetwork.LocalDNS' -Type 'Microsoft.Network/virtualNetworks' {
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
Rule 'Azure.VirtualNetwork.PeerState' -If { (HasPeerNetwork) } {
    $peers = @($TargetObject.Properties.virtualNetworkPeerings);
    foreach ($peer in $peers) {
        $peer | Within 'Properties.peeringState' 'Connected'
    }
}

#endregion Virtual Network

#region Network Security Group

# Synopsis: Network security groups should avoid any inbound rules
Rule 'Azure.VirtualNetwork.NSGAnyInboundSource' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    $inboundRules = @(GetOrderedNSGRules -Direction Inbound);
    $rules = $inboundRules | Where-Object {
        $_.properties.access -eq 'Allow' -and
        $_.properties.sourceAddressPrefix -eq '*'
    }
    $Null -eq $rules;
}

# Synopsis: Avoid blocking all inbound network traffic
Rule 'Azure.VirtualNetwork.NSGDenyAllInbound' -Type 'Microsoft.Network/networkSecurityGroups' {
    $inboundRules = @(GetOrderedNSGRules -Direction Inbound);
    $denyRules = @($inboundRules | Where-Object {
        $_.properties.access -eq 'Deny' -and
        $_.properties.sourceAddressPrefix -eq '*'
    })
    $Null -eq $denyRules -or $denyRules.Length -eq 0 -or $denyRules[0].name -ne $inboundRules[0].name
}

# Synopsis: Lateral traversal from application servers should be blocked
Rule 'Azure.VirtualNetwork.LateralTraversal' -Type 'Microsoft.Network/networkSecurityGroups' {
    $outboundRules = @(GetOrderedNSGRules -Direction Outbound);
    $rules = @($outboundRules | Where-Object {
        $_.properties.access -eq 'Deny' -and
        (
            $_.properties.destinationPortRange -eq '3389' -or
            $_.properties.destinationPortRange -eq '22' -or 
            $_.properties.destinationPortRanges -contains '3389' -or 
            $_.properties.destinationPortRanges -contains '22'
        )
    })
    $Null -ne $rules -and $rules.Length -gt 0
}

# Synopsis: Network security groups should be associated to either a subnet or network interface
Rule 'Azure.VirtualNetwork.NSGAssociated' -Type 'Microsoft.Network/networkSecurityGroups' -If { IsExport } {
    $subnets = ($TargetObject.Properties.subnets | Measure-Object).Count;
    $interfaces = ($TargetObject.Properties.networkInterfaces | Measure-Object).Count;

    # NSG should be associated to either a subnet or network interface
    $subnets -gt 0 -or $interfaces -gt 0
}

#endregion Network Security Group

#region Application Gateway

# Synopsis: Application Gateway should use a minimum of two instances
Rule 'Azure.VirtualNetwork.AppGwMinInstance' -Type 'Microsoft.Network/applicationGateways' -Tag @{ severity = 'Important'; category = 'Reliability' } {
    AnyOf {
        # Applies to v1 and v2 without autoscale
        $TargetObject.Properties.sku.capacity -ge 2

        # Applies to v2 with autoscale
        $TargetObject.Properties.autoscaleConfiguration.minCapacity -ge 2
    }
}

# Synopsis: Application Gateway should use a minimum of Medium
Rule 'Azure.VirtualNetwork.AppGwMinSku' -Type 'Microsoft.Network/applicationGateways' -Tag @{ severity = 'Important'; category = 'Performance' } {
    Within 'Properties.sku.name' 'WAF_Medium', 'Standard_Medium', 'WAF_Large', 'Standard_Large', 'WAF_v2', 'Standard_v2'
}

# Synopsis: Internet accessible Application Gateways should use WAF
Rule 'Azure.VirtualNetwork.AppGwUseWAF' -If { (IsAppGwPublic) } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.sku.tier' 'WAF', 'WAF_v2'
}

# Synopsis: Application Gateway should only accept a minimum of TLS 1.2
Rule 'Azure.VirtualNetwork.AppGwSSLPolicy' -Type 'Microsoft.Network/applicationGateways' -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Exists 'Properties.sslPolicy'
    AnyOf {
        Within 'Properties.sslPolicy.policyName' 'AppGwSslPolicy20170401S'
        Within 'Properties.sslPolicy.minProtocolVersion' 'TLSv1_2'
    }
}

# Synopsis: Internet exposed Application Gateways should use prevention mode to protect backend resources
Rule 'Azure.VirtualNetwork.AppGwPrevention' -If { (IsAppGwPublic) } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.webApplicationFirewallConfiguration.firewallMode' 'Prevention'
}

# Synopsis: Application Gateway WAF must be enabled to protect backend resources
Rule 'Azure.VirtualNetwork.AppGwWAFEnabled' -If { (IsAppGwPublic) } {
    Within 'Properties.webApplicationFirewallConfiguration.enabled' $True
}

# Synopsis: Application Gateway WAF should use OWASP 3.0 rules
Rule 'Azure.VirtualNetwork.AppGwOWASP' -If { (IsAppGwWAF) } {
    Within 'Properties.webApplicationFirewallConfiguration.ruleSetType' 'OWASP'
    Within 'Properties.webApplicationFirewallConfiguration.ruleSetVersion' '3.0'
}

# Synopsis: Application Gateway WAF should not disable rules
Rule 'Azure.VirtualNetwork.AppGwWAFRules' -If { (IsAppGwWAF) } {
    $disabledRules = @($TargetObject.Properties.webApplicationFirewallConfiguration.disabledRuleGroups)
    $disabledRules.Count -eq 0
}

#endregion Application Gateway

#region Network Interface

# Synopsis: Network interfaces should be attached
Rule 'Azure.VirtualNetwork.NICAttached' -Type 'Microsoft.Network/networkInterfaces' {
    Exists 'Properties.virtualMachine.id'
}

#endregion Network Interface

#region Load Balancer

# Synopsis: Use specific network probe
Rule 'Azure.VirtualNetwork.LBProbe' -Type 'Microsoft.Network/loadBalancers' {
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

#endregion Load Balancer

#
# Validation rules for virtual networking
#

# Synopsis: Subnets should have NSGs assigned, except for the GatewaySubnet
Rule 'Azure.VirtualNetwork.UseNSGs' -If { ResourceType 'Microsoft.Network/virtualNetworks' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
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
Rule 'Azure.VirtualNetwork.SingleDNS'  -If { ResourceType 'Microsoft.Network/virtualNetworks' } -Tag @{ severity = 'Single point of failure'; category = 'Reliability' } {
    # If DNS servers are customsied, at least two IP addresses should be defined
    if (!(Exists 'properties.dhcpOptions.dnsServers') -or ($TargetObject.properties.dhcpOptions.dnsServers.Count -eq 0)) {
        $True;
    }
    else {
        $TargetObject.properties.dhcpOptions.dnsServers.Count -ge 2;
    }
}

# Synopsis: VNETs should use Azure local DNS servers
Rule 'Azure.VirtualNetwork.LocalDNS' -If { ResourceType 'Microsoft.Network/virtualNetworks' } {
    if (!(Exists 'properties.dhcpOptions.dnsServers') -or ($TargetObject.properties.dhcpOptions.dnsServers.Count -eq 0)) {
        $True;
    }
    else {
        # Primary DNS server must be within VNET address space or peered VNET
        $dnsServers = @($TargetObject.Properties.dhcpOptions.dnsServers)
        $primary = $dnsServers[0]
        $localRanges = @();
        $localRanges += $TargetObject.Properties.addressSpace.addressPrefixes
        $localRanges += $TargetObject.Properties.virtualNetworkPeerings.properties.remoteAddressSpace.addressPrefixes

        # Determine if the primary is in range
        WithinCIDR -IP $primary -CIDR $localRanges
    }
}

# Synopsis: Network security groups should avoid any inbound rules
Rule 'Azure.VirtualNetwork.NSGAnyInboundSource' -If { ResourceType 'Microsoft.Network/networkSecurityGroups' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Recommend 'Avoid rules that apply to all source addresses'

    $rules = $TargetObject.properties.securityRules | Where-Object {
        $_.properties.direction -eq 'Inbound' -and
        $_.properties.access -eq 'Allow' -and
        $_.properties.sourceAddressPrefix -eq '*'
    }

    $Null -eq $rules;
}

# Synopsis: Application Gateway should use a minimum of two instances
Rule 'Azure.VirtualNetwork.AppGwMinInstance' -If { ResourceType 'Microsoft.Network/applicationGateways' } -Tag @{ severity = 'Important'; category = 'Reliability' } {
    AnyOf {
        # Applies to v1 and v2 without autoscale
        $TargetObject.Properties.sku.capacity -ge 2

        # Applies to v2 with autoscale
        $TargetObject.Properties.autoscaleConfiguration.minCapacity -ge 2
    }
}

# Synopsis: Application Gateway should use a minimum of Medium
Rule 'Azure.VirtualNetwork.AppGwMinSku' -If { ResourceType 'Microsoft.Network/applicationGateways' } -Tag @{ severity = 'Important'; category = 'Performance' } {
    Within 'Properties.sku.name' 'WAF_Medium', 'Standard_Medium', 'WAF_Large', 'Standard_Large', 'WAF_v2', 'Standard_v2'
}

# Synopsis: Internet accessible Application Gateways should use WAF
Rule 'Azure.VirtualNetwork.AppGwUseWAF' -If { (IsAppGwPublic) } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.sku.tier' 'WAF', 'WAF_v2'
}

# Synopsis: Application Gateway should only accept a minimum of TLS 1.2
Rule 'Azure.VirtualNetwork.AppGwSSLPolicy' -If { ResourceType 'Microsoft.Network/applicationGateways' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
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

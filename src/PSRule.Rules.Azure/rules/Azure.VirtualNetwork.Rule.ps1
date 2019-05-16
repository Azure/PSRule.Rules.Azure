#
# Validation rules for virtual networking
#

# Description: Subnets should have NSGs assigned, except for the GatewaySubnet
Rule 'Azure.VirtualNetwork.UseNSGs' -If { ResourceType 'Microsoft.Network/virtualNetworks' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Hint 'Subnets should have NSGs assigned'

    # Get subnets
    $subnets = $TargetObject.properties.subnets | Where-Object { $_.Name -ne 'GatewaySubnet' };

    if ($Null -ne $subnets) {
        $withNSGCount = ($subnets | Where-Object { $Null -ne $_.properties.networkSecurityGroup.id } | Measure-Object).Count

        # Are there subnets without NSGs configured
        return $withNSGCount -eq $subnets.Count
    }
}

# TODO: Check that NSG on GatewaySubnet is not defined

# Description: VNETs should have at least two DNS servers assigned
Rule 'Azure.VirtualNetwork.SingleDNS'  -If { ResourceType 'Microsoft.Network/virtualNetworks' } -Tag @{ severity = 'Single point of failure'; category = 'Reliability' } {
    # If DNS servers are customsied, at least two IP addresses should be defined
    if (!(Exists 'properties.dhcpOptions.dnsServers')) {
        $True;
    }
    else {
        $TargetObject.properties.dhcpOptions.dnsServers.Count -ge 2;
    }
}

# Description: Network security groups should avoid any inbound rules
Rule 'Azure.VirtualNetwork.NSGAnyInboundSource' -If { ResourceType 'Microsoft.Network/networkSecurityGroups' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Hint 'Avoid rules that apply to all source addresses'

    $rules = $TargetObject.properties.securityRules | Where-Object {
        $_.properties.direction -eq 'Inbound' -and
        $_.properties.access -eq 'Allow' -and
        $_.properties.sourceAddressPrefix -eq '*'
    }

    $Null -eq $rules;
}

# Description: Application Gateway should use a minimum of two instances
Rule 'Azure.VirtualNetwork.AppGwMinInstance' -If { ResourceType 'Microsoft.Network/applicationGateways' } -Tag @{ severity = 'Important'; category = 'Reliability' } {
    $TargetObject.Properties.sku.capacity -ge 2
}

# Description: Application Gateway should use a minimum of Medium
Rule 'Azure.VirtualNetwork.AppGwMinSku' -If { ResourceType 'Microsoft.Network/applicationGateways' } -Tag @{ severity = 'Important'; category = 'Performance' } {
    Within 'Properties.sku.name' 'WAF_Medium', 'Standard_Medium', 'WAF_Large', 'Standard_Large'
}

# Description: Internet accessible Application Gateways should use WAF
Rule 'Azure.VirtualNetwork.AppGwUseWAF' -If { (ResourceType 'Microsoft.Network/applicationGateways') -and (IsAppGwPublic) } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.sku.tier' 'WAF'
}

# Description: Application Gateway should only accept a minimum of TLS 1.2
Rule 'Azure.VirtualNetwork.AppGwSSLPolicy' -If { ResourceType 'Microsoft.Network/applicationGateways' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Exists 'Properties.sslPolicy'
    AnyOf {
        Within 'Properties.sslPolicy.policyName' 'AppGwSslPolicy20170401S'
        Within 'Properties.sslPolicy.minProtocolVersion' 'TLSv1_2'
    }
}

# Description: Internet exposed Application Gateways should use prevention mode to protect backend resources
Rule 'Azure.VirtualNetwork.AppGwPrevention' -If { (ResourceType 'Microsoft.Network/applicationGateways') -and (IsAppGwPublic) } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.webApplicationFirewallConfiguration.firewallMode' 'Prevention'
}

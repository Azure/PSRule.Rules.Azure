# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for virtual networking
#

#region Virtual Network

# Synopsis: Subnets should have NSGs assigned, except for the GatewaySubnet
Rule 'Azure.VNET.UseNSGs' -Type 'Microsoft.Network/virtualNetworks', 'Microsoft.Network/virtualNetworks/subnets' -Tag @{ release = 'GA' } {
    $subnet = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks') {
        # Get subnets
        $subnet = @($TargetObject.properties.subnets | Where-Object { $_.Name -notin 'GatewaySubnet', 'AzureFirewallSubnet' });
        if ($subnet.Length -eq 0) {
            return $True;
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.Network/virtualNetworks/subnets' -and $PSRule.TargetName -in 'GatewaySubnet', 'AzureFirewallSubnet') {
        return $True;
    }
    foreach ($sn in $subnet) {
        $Assert.
            HasFieldValue($sn, 'properties.networkSecurityGroup.id').
            WithReason(($LocalizedData.SubnetNSGNotConfigured -f $sn.Name), $True);
    }
}

# TODO: Check that NSG on GatewaySubnet is not defined

# Synopsis: VNETs should have at least two DNS servers assigned
Rule 'Azure.VNET.SingleDNS' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA' } {
    # If DNS servers are customized, at least two IP addresses should be defined
    if ($Assert.NullOrEmpty($TargetObject, 'properties.dhcpOptions.dnsServers').Result) {
        $True;
    }
    else {
        $TargetObject.properties.dhcpOptions.dnsServers.Count -ge 2;
    }
}

# Synopsis: VNETs should use Azure local DNS servers
Rule 'Azure.VNET.LocalDNS' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA' } {
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
Rule 'Azure.VNET.PeerState' -If { (HasPeerNetwork) } -Tag @{ release = 'GA' } {
    $peers = @($TargetObject.Properties.virtualNetworkPeerings);
    foreach ($peer in $peers) {
        $peer | Within 'Properties.peeringState' 'Connected'
    }
}

# Synopsis: Use VNET naming requirements
Rule 'Azure.VNET.Name' -Type 'Microsoft.Network/virtualNetworks' -Tag @{ release = 'GA' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 2 and 64 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 2)
    $Assert.LessOrEqual($TargetObject, 'Name', 64)

    # Alphanumerics, underscores, periods, and hyphens
    # Start with alphanumeric
    # End alphanumeric or underscore
    Match 'Name' '^[A-Za-z0-9](-|\w|\.){0,}\w$'
}

#endregion Virtual Network

#region Network Security Group

# Synopsis: Network security groups should avoid any inbound rules
Rule 'Azure.NSG.AnyInboundSource' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA' } {
    $inboundRules = @(GetOrderedNSGRules -Direction Inbound);
    $rules = $inboundRules | Where-Object {
        $_.properties.access -eq 'Allow' -and
        $_.properties.sourceAddressPrefix -eq '*'
    }
    $Null -eq $rules;
}

# Synopsis: Avoid blocking all inbound network traffic
Rule 'Azure.NSG.DenyAllInbound' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA' } {
    Reason $LocalizedData.AllInboundRestricted;
    $inboundRules = @(GetOrderedNSGRules -Direction Inbound);
    $denyRules = @($inboundRules | Where-Object {
        $_.properties.access -eq 'Deny' -and
        $_.properties.sourceAddressPrefix -eq '*'
    })
    $Null -eq $denyRules -or $denyRules.Length -eq 0 -or $denyRules[0].name -ne $inboundRules[0].name
}

# Synopsis: Lateral traversal from application servers should be blocked
Rule 'Azure.NSG.LateralTraversal' -Type 'Microsoft.Network/networkSecurityGroups' -Tag @{ release = 'GA' } {
    Reason $LocalizedData.LateralTraversalNotRestricted;
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
Rule 'Azure.NSG.Associated' -Type 'Microsoft.Network/networkSecurityGroups' -If { IsExport } -Tag @{ release = 'GA' } {
    # NSG should be associated to either a subnet or network interface
    Reason $LocalizedData.ResourceNotAssociated
    $Assert.HasFieldValue($TargetObject, 'Properties.subnets').Result -or
        $Assert.HasFieldValue($TargetObject, 'Properties.networkInterfaces').Result
}

#endregion Network Security Group

#region Application Gateway

# Synopsis: Application Gateway should use a minimum of two instances
Rule 'Azure.AppGw.MinInstance' -Type 'Microsoft.Network/applicationGateways' -Tag @{ release = 'GA' } {
    AnyOf {
        # Applies to v1 and v2 without autoscale
        $TargetObject.Properties.sku.capacity -ge 2

        # Applies to v2 with autoscale
        $TargetObject.Properties.autoscaleConfiguration.minCapacity -ge 2
    }
}

# Synopsis: Application Gateway should use a minimum of Medium
Rule 'Azure.AppGw.MinSku' -Type 'Microsoft.Network/applicationGateways' -Tag @{ release = 'GA' } {
    Within 'Properties.sku.name' 'WAF_Medium', 'Standard_Medium', 'WAF_Large', 'Standard_Large', 'WAF_v2', 'Standard_v2'
}

# Synopsis: Internet accessible Application Gateways should use WAF
Rule 'Azure.AppGw.UseWAF' -If { (IsAppGwPublic) } -Tag @{ release = 'GA' } {
    Within 'Properties.sku.tier' 'WAF', 'WAF_v2'
}

# Synopsis: Application Gateway should only accept a minimum of TLS 1.2
Rule 'Azure.AppGw.SSLPolicy' -Type 'Microsoft.Network/applicationGateways' -Tag @{ release = 'GA' } {
    Exists 'Properties.sslPolicy'
    AnyOf {
        Within 'Properties.sslPolicy.policyName' 'AppGwSslPolicy20170401S'
        Within 'Properties.sslPolicy.minProtocolVersion' 'TLSv1_2'
    }
}

# Synopsis: Internet exposed Application Gateways should use prevention mode to protect backend resources
Rule 'Azure.AppGw.Prevention' -If { (IsAppGwPublic) } -Tag @{ release = 'GA' } {
    Within 'Properties.webApplicationFirewallConfiguration.firewallMode' 'Prevention'
}

# Synopsis: Application Gateway WAF must be enabled to protect backend resources
Rule 'Azure.AppGw.WAFEnabled' -If { (IsAppGwPublic) } -Tag @{ release = 'GA' } {
    Within 'Properties.webApplicationFirewallConfiguration.enabled' $True
}

# Synopsis: Application Gateway WAF should use OWASP 3.0 rules
Rule 'Azure.AppGw.OWASP' -If { (IsAppGwWAF) } -Tag @{ release = 'GA' } {
    Within 'Properties.webApplicationFirewallConfiguration.ruleSetType' 'OWASP'
    Within 'Properties.webApplicationFirewallConfiguration.ruleSetVersion' '3.0'
}

# Synopsis: Application Gateway WAF should not disable rules
Rule 'Azure.AppGw.WAFRules' -If { (IsAppGwWAF) } -Tag @{ release = 'GA' } {
    $disabledRules = @($TargetObject.Properties.webApplicationFirewallConfiguration.disabledRuleGroups)
    $disabledRules.Count -eq 0
}

#endregion Application Gateway

#region Load Balancer

# Synopsis: Use specific network probe
Rule 'Azure.LB.Probe' -Type 'Microsoft.Network/loadBalancers' -Tag @{ release = 'GA' } {
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

#region Azure Firewall

# Synopsis: Threat intelligence denies high confidence malicious IP addresses and domains
Rule 'Azure.Firewall.Mode' -Type 'Microsoft.Network/azureFirewalls' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.threatIntelMode', 'Deny');
}

#endregion Azure Firewall

#region Front Door

# Synopsis: Front Door instance should be enabled
Rule 'Azure.FrontDoor.State' -Type 'Microsoft.Network/frontDoors' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enabledState', 'Enabled');
}

# Synopsis: Use a minimum of TLS 1.2
Rule 'Azure.FrontDoor.MinTLS' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/frontendEndpoints' -Tag @{ release = 'GA' } {
    $endpoints = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $endpoints = @($TargetObject.Properties.frontendEndpoints);
    }
    foreach ($endpoint in $endpoints) {
        $Assert.HasDefaultValue($endpoint, 'properties.customHttpsConfiguration.minimumTlsVersion', '1.2');
    }
    # properties.frontendEndpoints[].properties.customHttpsConfiguration.minimumTlsVersion
}

# Synopsis: Use diagnostics to audit Front Door access
Rule 'Azure.FrontDoor.Logs' -Type 'Microsoft.Network/frontDoors' -Tag @{ release = 'GA' } {
    Reason $LocalizedData.DiagnosticSettingsNotConfigured;
    $diagnostics = @(GetSubResources -ResourceType 'microsoft.insights/diagnosticSettings', 'Microsoft.Network/frontDoors/providers/diagnosticSettings');
    $logCategories = @($diagnostics | ForEach-Object {
        foreach ($log in $_.Properties.logs) {
            if ($log.category -eq 'FrontdoorAccessLog' -and $log.enabled -eq $True) {
                $log;
            }
        }
    });
    $Null -ne $logCategories -and $logCategories.Length -gt 0;
}

# Synopsis: Enable WAF policy of each endpoint
Rule 'Azure.FrontDoor.UseWAF' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/frontendEndpoints' -Tag @{ release = 'GA' } {
    $endpoints = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $endpoints = @($TargetObject.Properties.frontendEndpoints);
    }
    foreach ($endpoint in $endpoints) {
        $Assert.HasFieldValue($endpoint, 'properties.webApplicationFirewallPolicyLink.id');
    }
}

# Synopsis: Use Front Door WAF policy in prevention mode
Rule 'Azure.FrontDoor.WAF.Mode' -Type 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.policySettings.mode', 'Prevention');
}

# Synopsis: Enable Front Door WAF policy
Rule 'Azure.FrontDoor.WAF.Enabled' -Type 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.policySettings.enabledState', 'Enabled');
}

#endregion Front Door

#region VPN Gateways

# Synopsis: Migrate from legacy VPN gateway SKUs
Rule 'Azure.VPNGateway.LegacySKU' -Type 'Microsoft.Network/virtualNetworkGateways' -If { IsVPNGateway } -Tag @{ release = 'GA' } {
    Within 'Properties.sku.name' -Not 'Basic', 'Standard', 'HighPerformance';
}

# Synopsis: Use Active-Active configuration
Rule 'Azure.VPNGateway.ActiveActive' -Type 'Microsoft.Network/virtualNetworkGateways' -If { IsVPNGateway } -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.activeActive', $True);
}

#endregion VPN Gateways

#region ExpressRoute

# Synopsis: Migrate from legacy ExpressRoute gateway SKUs
Rule 'Azure.ERGateway.LegacySKU' -Type 'Microsoft.Network/virtualNetworkGateways' -If { IsERGateway } -Tag @{ release = 'GA' } {
    Within 'Properties.sku.name' -Not 'Basic';
}

#endregion ExpressRoute

#region Helper functions

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

#endregion Helper functions

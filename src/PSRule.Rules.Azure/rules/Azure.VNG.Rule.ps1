# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Virtual Network Gateways
#

#region Rules

# Synopsis: Migrate from legacy ExpressRoute gateway SKUs
Rule 'Azure.VNG.ERLegacySKU' -Ref 'AZR-000271' -Type 'Microsoft.Network/virtualNetworkGateways' -With 'Azure.VNG.ERGateway' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    Within 'Properties.sku.name' -Not 'Basic';
}

# Synopsis: Use availability zone SKU for virtual network gateways deployed with VPN gateway type
Rule 'Azure.VNG.VPNAvailabilityZoneSKU' -Ref 'AZR-000272' -Type 'Microsoft.Network/virtualNetworkGateways' -With 'Azure.VNG.VPNGateway' -Tag @{ release = 'GA'; ruleSet = '2021_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $vpnAvailabilityZoneSKUs = @('VpnGw1AZ', 'VpnGw2AZ', 'VpnGw3AZ', 'VpnGw4AZ', 'VpnGw5AZ');
    $Assert.In($TargetObject, 'Properties.sku.name', $vpnAvailabilityZoneSKUs).
        Reason($LocalizedData.VPNAvailabilityZoneSKU, $TargetObject.Name, ($vpnAvailabilityZoneSKUs -join ', '));
}

# Synopsis: Use availability zone SKU for virtual network gateways deployed with ExpressRoute gateway type
Rule 'Azure.VNG.ERAvailabilityZoneSKU' -Ref 'AZR-000273' -Type 'Microsoft.Network/virtualNetworkGateways' -With 'Azure.VNG.ERGateway' -Tag @{ release = 'GA'; ruleSet = '2021_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $erAvailabilityZoneSKUs = @('ErGw1AZ', 'ErGw2AZ', 'ErGw3AZ');
    $Assert.In($TargetObject, 'Properties.sku.name', $erAvailabilityZoneSKUs).
        Reason($LocalizedData.ERAvailabilityZoneSKU, $TargetObject.Name, ($erAvailabilityZoneSKUs -join ', '));
}

#endregion Rules

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

# Synopsis: Use a customer-controlled maintenance configuration for virtual network gateways.
Rule 'Azure.VNG.MaintenanceConfig' -Ref 'AZR-000430' -Type 'Microsoft.Network/virtualNetworkGateways' -Tag @{ release = 'preview'; ruleSet = '2024_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $maintenanceConfig = @(GetSubResources -ResourceType 'Microsoft.Maintenance/configurationAssignments' |
        Where-Object { $_.properties.maintenanceConfigurationId })
    $Assert.GreaterOrEqual($maintenanceConfig, '.', 1).Reason($LocalizedData.VNGMaintenanceConfig, $PSRule.TargetName)
}

# Synopsis: Use standard virtual network gateway names.
Rule 'Azure.VNG.Naming' -Ref 'AZR-000476' -Type 'Microsoft.Network/virtualNetworkGateways' -If { $Configuration['AZURE_VIRTUAL_NETWORK_GATEWAY_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_VIRTUAL_NETWORK_GATEWAY_NAME_FORMAT, $True);
}

# Synopsis: Use standard virtual networks gateway connection names.
Rule 'Azure.VNG.ConnectionNaming' -Ref 'AZR-000466' -Type 'Microsoft.Network/connections' -If { $Configuration['AZURE_GATEWAY_CONNECTION_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_GATEWAY_CONNECTION_NAME_FORMAT, $True);
}

#endregion Rules

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure DNS zones.
#

# Synopsis: Ensure public DNS zones are configured with DNSSEC.
Rule 'Azure.DNS.DNSSEC' -Ref 'AZR-000456' -Type 'Microsoft.Network/dnsZones' -Tag @{ release = 'GA'; ruleSet = '2025_03'; 'Azure.WAF/pillar' = 'Security'; } {
    $configs = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/dnsZones') {
        $configs = @(GetSubResources -ResourceType 'Microsoft.Network/dnsZones/dnssecConfigs');
    }

    if ($configs.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Network/dnsZones/dnssecConfigs');
    }

    return $Assert.Pass();
}

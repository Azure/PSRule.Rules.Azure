# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Application Gateway
#

#region Application Gateway

# Synopsis: Application Gateway should use a minimum of two instances
Rule 'Azure.AppGw.MinInstance' -Type 'Microsoft.Network/applicationGateways' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    AnyOf {
        # Applies to v1 and v2 without autoscale
        $Assert.GreaterOrEqual($TargetObject, 'Properties.sku.capacity', 2);

        # Applies to v2 with autoscale
        $Assert.GreaterOrEqual($TargetObject, 'Properties.autoscaleConfiguration.minCapacity', 2);
    }
}

# Synopsis: Application Gateway should use a minimum of Medium
Rule 'Azure.AppGw.MinSku' -Type 'Microsoft.Network/applicationGateways' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Within 'Properties.sku.name' 'WAF_Medium', 'Standard_Medium', 'WAF_Large', 'Standard_Large', 'WAF_v2', 'Standard_v2'
}

# Synopsis: Internet accessible Application Gateways should use WAF
Rule 'Azure.AppGw.UseWAF' -If { (IsAppGwPublic) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Within 'Properties.sku.tier' 'WAF', 'WAF_v2'
}

# Synopsis: Application Gateway should only accept a minimum of TLS 1.2
Rule 'Azure.AppGw.SSLPolicy' -Type 'Microsoft.Network/applicationGateways' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Exists 'Properties.sslPolicy'
    AnyOf {
        Within 'Properties.sslPolicy.policyName' 'AppGwSslPolicy20170401S'
        Within 'Properties.sslPolicy.minProtocolVersion' 'TLSv1_2'
    }
}

# Synopsis: Internet exposed Application Gateways should use prevention mode to protect backend resources
Rule 'Azure.AppGw.Prevention' -If { (IsAppGwPublic) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.webApplicationFirewallConfiguration.firewallMode', 'Prevention');
}

# Synopsis: Application Gateway WAF must be enabled to protect backend resources
Rule 'Azure.AppGw.WAFEnabled' -If { (IsAppGwPublic) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.webApplicationFirewallConfiguration.enabled', $True);
}

# Synopsis: Application Gateway WAF should use OWASP 3.0 rules
Rule 'Azure.AppGw.OWASP' -Type 'Microsoft.Network/applicationGateways' -With 'Azure.IsAppGwWAF' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.webApplicationFirewallConfiguration.ruleSetType', 'OWASP');
    $Assert.Version($TargetObject, 'Properties.webApplicationFirewallConfiguration.ruleSetVersion', '^3.0');
}

# Synopsis: Application Gateway WAF should not disable rules
Rule 'Azure.AppGw.WAFRules' -Type 'Microsoft.Network/applicationGateways' -With 'Azure.IsAppGwWAF' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.LessOrEqual($TargetObject, 'Properties.webApplicationFirewallConfiguration.disabledRuleGroups', 0);
}

# Synopsis: Application Gateways should only expose frontend HTTP endpoints over HTTPS.
Rule 'Azure.AppGw.UseHTTPS' -Type 'Microsoft.Network/applicationGateways' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $listeners = @($TargetObject.properties.httpListeners | Where-Object { $_.properties.protocol -eq 'http' });
    $requestRoutingRules = @($TargetObject.properties.requestRoutingRules);
    if ($listeners.Length -eq 0 -or $requestRoutingRules.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($requestRoutingRule in $requestRoutingRules) {
        $listener = $listeners | Where-Object { $_.name -eq $requestRoutingRule.properties.httpListener.id.Split('/')[-1] };
        if ($Null -eq $listener) {
            $Assert.Pass();
        }
        else {
            $Assert.HasFieldValue($requestRoutingRule, 'properties.redirectConfiguration.id');
        }
    }
}

# Synopsis: Application gateways deployed with V2 SKU(Standard_v2, WAF_v2) should use availability zones in supported regions for high availability.
Rule 'Azure.AppGw.AvailabilityZone' -Type 'Microsoft.Network/applicationGateways' -If { IsAppGwV2Sku } -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $appGatewayProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Network', 'applicationGateways');

    $configurationZoneMappings = $Configuration.AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $appGatewayProvider.ZoneMappings;
    $availabilityZoneMappings = PrependConfigurationZoneMappingWithProviderZoneMapping -ConfigurationAvailabilityZoneMapping $configurationZoneMappings -ProviderAvailabilityZoneMapping $providerZoneMappings;

    $availabilityZones = GetAvailabilityZone -AvailabilityZoneMapping $availabilityZoneMappings;

    if (-not $availabilityZones) {
        return $Assert.Pass();
    }

    $Assert.HasFieldValue($TargetObject, 'zones').
        Reason($LocalizedData.AppGWAvailabilityZone, $TargetObject.name, $location, ($availabilityZones -join ', '));

} -Configure @{ AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST = @() }

#endregion Application Gateway

#region Helper functions

function global:IsAppGwPublic {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Network/applicationGateways') {
            return $False;
        }

        $result = $False;
        foreach ($ip in $TargetObject.Properties.frontendIPConfigurations) {
            if (Exists 'properties.publicIPAddress.id' -InputObject $ip) {
                $result = $True;
            }
        }
        return $result;
    }
}

function global:IsAppGwV2Sku {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return $Assert.In($TargetObject, 'Properties.sku.tier', @('Standard_v2', 'WAF_v2')).Result;
    }
}

#endregion Helper functions

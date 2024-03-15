# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Load Balancers
#

#region Rules

# Synopsis: Use specific network probe
Rule 'Azure.LB.Probe' -Ref 'AZR-000126' -Type 'Microsoft.Network/loadBalancers' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
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
            $Assert.Pass();
        }
    }
}

# Synopsis: Load balancers deployed with Standard SKU should be zone-redundant for high availability.
Rule 'Azure.LB.AvailabilityZone' -Ref 'AZR-000127' -Type 'Microsoft.Network/loadBalancers' -If { IsStandardLoadBalancer } -Tag @{ release = 'GA'; ruleSet = '2021_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    foreach ($ipConfig in $TargetObject.Properties.frontendIPConfigurations) {
        $Assert.AnyOf(
            $Assert.SetOf($ipConfig, 'zones', @('1', '2', '3'))
        ).Reason(
            $LocalizedData.LBAvailabilityZone,
            $TargetObject.name, 
            $ipConfig.name
        )
    }
}

# Synopsis: Load balancers should be deployed with Standard SKU for production workloads.
Rule 'Azure.LB.StandardSKU' -Ref 'AZR-000128' -Type 'Microsoft.Network/loadBalancers' -Tag @{ release = 'GA'; ruleSet = '2021_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    IsStandardLoadBalancer;
}

#endregion Rules

#region Helper functions

function global:IsStandardLoadBalancer {
    [CmdletBinding()]
    [OutputType([PSRule.Runtime.AssertResult])]
    param ()
    process {
        return $Assert.HasFieldValue($TargetObject, 'sku.name', 'Standard');
    }
}

#endregion Helper functions

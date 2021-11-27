# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Load Balancers
#

#region Rules

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
            $Assert.Pass();
        }
    }
}

# Synopsis: Load balancers deployed with Standard SKU should be zone-redundant for high availability.
Rule 'Azure.LB.AvailabilityZone' -Type 'Microsoft.Network/loadBalancers' -If { IsStandardLoadBalancer } -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
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

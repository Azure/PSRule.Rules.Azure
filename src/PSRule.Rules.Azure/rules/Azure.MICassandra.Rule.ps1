# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Managed Instance for Apache Cassandra
#

#region Rules

# Synopsis: Use zone redundant Azure Managed Instance for Apache Cassandra clusters in supported regions to improve reliability.
Rule 'Azure.MICassandra.AvailabilityZone' -Ref 'AZR-000504' -Type 'Microsoft.DocumentDB/cassandraClusters', 'Microsoft.DocumentDB/cassandraClusters/dataCenters' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Check for availability zones based on virtual machine scale sets, because it is not exposed through the provider for Managed Instance for Apache Cassandra.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets')

    $dataCenters = @(GetCassandraDataCenter)
    if ($dataCenters.Count -eq 0) {
        return $Assert.Pass()
    }

    foreach ($dataCenter in $dataCenters) {
        $availabilityZones = GetAvailabilityZone -Location $dataCenter.properties.dataCenterLocation -Zone $provider.ZoneMappings

        if ($availabilityZones) {
            $Assert.HasFieldValue($dataCenter, 'properties.availabilityZone', $true).
            ReasonFrom(
                'properties.availabilityZone',
                $LocalizedData.MICassandraAvailabilityZone,
                $dataCenter.name,
                $dataCenter.dataCenterLocation
            )
        }
        # Don't flag if the region does not support availability zones.
        else {
            $Assert.Pass()
        }
    }
}

#endregion Rules

#region Helper functions

function global:GetCassandraDataCenter {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.DocumentDB/cassandraClusters') {
            GetSubResources -ResourceType 'Microsoft.DocumentDB/cassandraClusters/dataCenters'
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.DocumentDB/cassandraClusters/dataCenters') {
            $TargetObject
        }
    }
}

#endregion Helper functions

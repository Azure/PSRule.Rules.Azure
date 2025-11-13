# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Managed Instance for Apache Cassandra
#

#region Rules

# Synopsis: Deploy Azure Managed Instance for Apache Cassandra data centers using availability zones in supported regions to ensure high availability and resilience.
Rule 'Azure.MICassandra.AvailabilityZone' -Ref 'AZR-000504' -Type 'Microsoft.DocumentDB/cassandraClusters', 'Microsoft.DocumentDB/cassandraClusters/dataCenters' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Check for availability zones based on virtual machine scale sets, because it is not exposed through the provider for Managed Instance for Apache Cassandra.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');

    $dataCenters = @(GetCassandraDataCenter);
    if ($dataCenters.Length -eq 0) {
        return $Assert.Pass();
    }

    foreach ($dataCenter in $dataCenters) {
        $availabilityZones = GetAvailabilityZone -Location $dataCenter.Location -Zone $provider.ZoneMappings;

        # Don't flag if the region does not support availability zones
        if ($availabilityZones) {
            $Assert.HasFieldValue($dataCenter, 'properties.availabilityZone', $true).Reason(
                $LocalizedData.MICassandraAvailabilityZone,
                $dataCenter.name,
                $dataCenter.location,
                ($availabilityZones -join ', ')
            );
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

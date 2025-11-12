# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Managed Instance for Apache Cassandra
#

#region Rules

# Synopsis: Deploy Azure Managed Instance for Apache Cassandra data centers using availability zones in supported regions to ensure high availability and resilience.
Rule 'Azure.MICassandra.AvailabilityZone' -Ref 'AZR-000503' -Type 'Microsoft.DocumentDB/cassandraClusters/dataCenters' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Check if the region supports availability zones
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');
    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $provider.ZoneMappings;

    # Don't flag if the region does not support availability zones
    if (-not $availabilityZones) {
        return $Assert.Pass();
    }

    $Assert.HasFieldValue($TargetObject, 'properties.availabilityZone', $true).Reason(
        $LocalizedData.MICassandraAvailabilityZone,
        $TargetObject.name,
        $TargetObject.location,
        ($availabilityZones -join ', ')
    );
}
#endregion Rules

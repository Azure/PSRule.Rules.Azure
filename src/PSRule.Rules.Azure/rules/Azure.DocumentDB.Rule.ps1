# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure DocumentDB

#region Rules

# Synopsis: Use zone redundant Azure DocumentDB clusters in supported regions to improve reliability.
Rule 'Azure.DocumentDB.AvailabilityZone' -Ref 'AZR-000503' -Alias 'Azure.Cosmos.MongoAvailabilityZone' -Type 'Microsoft.DocumentDB/mongoClusters' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Use VM scale set zone mappings because the DocumentDB provider does not expose availability zones.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');

    $location = $TargetObject.Location;
    $availabilityZones = GetAvailabilityZone -Location $location -Zone $provider.ZoneMappings;

    if ($availabilityZones) {
        $Assert.HasFieldValue($TargetObject, 'properties.highAvailability.targetMode', 'ZoneRedundantPreferred').
        ReasonFrom('properties.highAvailability.targetMode', $LocalizedData.DocumentDBAvailabilityZone, $TargetObject.Name, $location);
    }
    else {
        $Assert.Pass();
    }
}

#endregion Rules

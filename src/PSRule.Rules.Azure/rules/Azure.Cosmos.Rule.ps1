# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Cosmos DB

#region Rules

# Synopsis: Enable Microsoft Defender for Azure Cosmos DB.
Rule 'Azure.Cosmos.DefenderCloud' -Ref 'AZR-000382' -Type 'Microsoft.DocumentDb/databaseAccounts' -If { $Configuration.AZURE_COSMOS_DEFENDER_PER_ACCOUNT -and (Test-IsNoSQL) } -Tag @{ release = 'GA'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-2', 'LT-1' } {
    $defender = @(GetSubResources -ResourceType 'Microsoft.Security/advancedThreatProtectionSettings' |
        Where-Object { $_.properties.isEnabled -eq $True })
    $Assert.GreaterOrEqual($defender, '.', 1).Reason($LocalizedData.SubResourceNotFound, 'Microsoft.Security/advancedThreatProtectionSettings')
} -Configure @{ AZURE_COSMOS_DEFENDER_PER_ACCOUNT = $False }

# Synopsis: Cosmos DB has local authentication disabled.
Rule 'Azure.Cosmos.DisableLocalAuth' -Ref 'AZR-000420' -Type 'Microsoft.DocumentDb/databaseAccounts' -If { Test-IsNoSQL } -Tag @{ release = 'GA'; ruleSet = '2024_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1'; 'Azure.WAF/maturity' = 'L1' } {
    $Assert.HasFieldValue($TargetObject, 'properties.DisableLocalAuth', $true)
}

# Synopsis: Use zone redundant Cosmos DB accounts in supported regions to improve reliability.
Rule 'Azure.Cosmos.AvailabilityZone' -Ref 'AZR-000502' -Type 'Microsoft.DocumentDb/databaseAccounts' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Check for availability zones based on virtual machine scale sets, because it is not exposed through the provider for Cosmos DB.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');

    $Assert.GreaterOrEqual($TargetObject, 'properties.locations', 1);

    if ($TargetObject.properties.locations) {
        foreach ($location in $TargetObject.properties.locations) {
            $availabilityZones = GetAvailabilityZone -Location $location.locationName -Zone $provider.ZoneMappings;

            # If the location supports availability zones, ensure zone redundancy is enabled
            if ($availabilityZones) {
                $Assert.HasFieldValue($location, 'isZoneRedundant', $true).
                    ReasonFrom('properties.locations', $LocalizedData.CosmosDBAvailabilityZone, $TargetObject.Name, $location.locationName);
            }
        }
    }
}

# Synopsis: Deploy Azure Managed Instance for Apache Cassandra data centers using availability zones in supported regions to ensure high availability and resilience.
Rule 'Azure.Cassandra.AvailabilityZone' -Ref 'AZR-000503' -Type 'Microsoft.DocumentDB/cassandraClusters/dataCenters' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Check if the region supports availability zones
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');
    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $provider.ZoneMappings;

    # Don't flag if the region does not support availability zones
    if (-not $availabilityZones) {
        return $Assert.Pass();
    }

    $Assert.HasFieldValue($TargetObject, 'properties.availabilityZone', $true).Reason(
        $LocalizedData.CassandraAvailabilityZone,
        $TargetObject.name,
        $TargetObject.location,
        ($availabilityZones -join ', ')
    );
}
#endregion Rules

#region Helper functions

function global:Test-IsNoSQL {
    [CmdletBinding()]
    param ( )

    if ($TargetObject.kind -ne 'GlobalDocumentDB') {
        return $false
    }
    if (-not $TargetObject.properties.capabilities) {
        return $true
    }
    $TargetObject.properties.capabilities.Where({ $_.name -in @('EnableTable', 'EnableCassandra', 'EnableGremlin') }, 'First').Count -eq 0
}

#endregion Helper functions

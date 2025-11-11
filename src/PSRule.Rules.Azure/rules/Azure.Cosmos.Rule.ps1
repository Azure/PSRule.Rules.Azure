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
    Test-CosmosAvailabilityZone
}

# Synopsis: Use zone redundant Cosmos DB vCore clusters in supported regions to improve reliability.
Rule 'Azure.Cosmos.MongoAvailabilityZone' -Ref 'AZR-000503' -Type 'Microsoft.DocumentDB/mongoClusters' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    Test-CosmosAvailabilityZone
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

function global:Test-CosmosAvailabilityZone {
    [CmdletBinding()]
    param ()

    # Check for availability zones based on virtual machine scale sets, because it is not exposed through the provider for Cosmos DB.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');

    if ($PSRule.TargetType -eq 'Microsoft.DocumentDb/databaseAccounts') {
        # For Cosmos DB accounts, check locations
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
    elseif ($PSRule.TargetType -eq 'Microsoft.DocumentDB/mongoClusters') {
        # For MongoDB vCore clusters, check highAvailability.targetMode
        $location = $TargetObject.Location;
        $availabilityZones = GetAvailabilityZone -Location $location -Zone $provider.ZoneMappings;

        # If the location supports availability zones, ensure zone redundancy is enabled
        if ($availabilityZones) {
            $Assert.HasFieldValue($TargetObject, 'properties.highAvailability.targetMode', 'ZoneRedundantPreferred').
                ReasonFrom('properties.highAvailability.targetMode', $LocalizedData.CosmosDBAvailabilityZone, $TargetObject.Name, $location);
        }
    }
}

#endregion Helper functions

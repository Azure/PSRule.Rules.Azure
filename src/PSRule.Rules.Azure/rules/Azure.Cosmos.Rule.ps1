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

# Synopsis: Cosmos DB accounts should have availability zones enabled for supported regions.
Rule 'Azure.Cosmos.AvailabilityZone' -Ref 'AZR-000500' -Type 'Microsoft.DocumentDb/databaseAccounts' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    # Check for availability zones based on Compute, because it is not exposed through the provider for Cosmos DB.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');
    
    $Assert.HasFieldValue($TargetObject, 'Properties.locations').Result;
    
    foreach ($location in $TargetObject.Properties.locations) {
        $availabilityZones = GetAvailabilityZone -Location $location.locationName -Zone $provider.ZoneMappings;
        
        # If the location supports availability zones, ensure zone redundancy is enabled
        if ($availabilityZones) {
            $Assert.HasFieldValue($location, 'isZoneRedundant', $true).
                ReasonFrom('Properties.locations', $LocalizedData.CosmosDBAvailabilityZone, $location.locationName);
        }
    }
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

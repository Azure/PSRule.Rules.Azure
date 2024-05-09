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
Rule 'Azure.Cosmos.DisableLocalAuth' -Ref 'AZR-000420' -Type 'Microsoft.DocumentDb/databaseAccounts' -If { Test-IsNoSQL } -Tag @{ release = 'GA'; ruleSet = '2024_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1' } {
    $Assert.HasFieldValue($TargetObject, 'properties.DisableLocalAuth', $true)
}
#endregion Rules

#region Helper functions

function global:Test-IsNoSQL {
    [CmdletBinding()]
    param ( )

    if ($TargetObject.kind -ne 'GlobalDocumentDB') {
        return $false
    }
    if ($TargetObject.kind -eq 'GlobalDocumentDB' -and -not $TargetObject.properties.capabilities) {
        return $true
    }
    $TargetObject.properties.capabilities.Where({ $_.name -in @('EnableTable', 'EnableCassandra', 'EnableGremlin') }, 'First').Count -eq 0
}

#endregion Helper functions

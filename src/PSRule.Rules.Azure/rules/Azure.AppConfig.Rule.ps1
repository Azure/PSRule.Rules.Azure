# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for App Configuration
#

#region Rules

# Synopsis: Ensure app configuration store audit diagnostic logs are enabled.
Rule 'Azure.AppConfig.AuditLogs' -Ref 'AZR-000311' -Type 'Microsoft.AppConfiguration/configurationStores' -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = @('LT-4'); 'Azure.WAF/maturity' = 'L1' } { 
    $logCategoryGroups = 'audit', 'allLogs'
    $joinedLogCategoryGroups = $logCategoryGroups -join ', '
    $diagnostics = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings' | ForEach-Object {
            $_.Properties.logs | Where-Object {
                ($_.category -eq 'Audit' -or $_.categoryGroup -in $logCategoryGroups) -and $_.enabled
            }
        })

    $Assert.Greater($diagnostics, '.', 0).ReasonFrom(
        'properties.logs',
        $LocalizedData.AppConfigStoresDiagnosticSetting,
        'Audit',
        $joinedLogCategoryGroups
    ).PathPrefix('resources')
}

# Synopsis: Consider replication for app configuration store to ensure resiliency to region outages.
Rule 'Azure.AppConfig.GeoReplica' -Ref 'AZR-000312' -Type 'Microsoft.AppConfiguration/configurationStores' -If { IsAppConfigStandardSKU } -Tag @{ release = 'GA'; ruleSet = '2023_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $appConfigLocation = GetNormalLocation -Location $TargetObject.Location
    $replicas = @(GetSubResources -ResourceType 'Microsoft.AppConfiguration/configurationStores/replicas' |
        ForEach-Object { GetNormalLocation -Location $_.Location } |
        Where-Object { $_ -ne $appConfigLocation })
    
    $Assert.Greater($replicas, '.', 0).Reason($LocalizedData.ReplicaInSecondaryNotFound).PathPrefix('resources')
}

# Synopsis: Consider purge protection for app configuration store to ensure store cannot be purged in the retention period.
Rule 'Azure.AppConfig.PurgeProtect' -Ref 'AZR-000313' -Type 'Microsoft.AppConfiguration/configurationStores' -If { IsAppConfigStandardSKU } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.enablePurgeProtection', $true).Reason($LocalizedData.AppConfigPurgeProtection, $TargetObject.name)
}

# Synopsis: Secrets stored as key values in an App Configuration Store may be leaked to unauthorized users.
Rule 'Azure.AppConfig.SecretLeak' -Ref 'AZR-000490' -Type 'Microsoft.AppConfiguration/configurationStores', 'Microsoft.AppConfiguration/configurationStores/keyValues' -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = @('IM-8') } {
    $kv = @($TargetObject)
    if ($PSRule.TargetType -eq 'Microsoft.AppConfiguration/configurationStores') {
        $kv = @(GetSubResources -ResourceType 'Microsoft.AppConfiguration/configurationStores/keyValues', 'keyValues')
    }

    if ($kv.Length -eq 0) {
        return $Assert.Pass()
    }

    foreach ($keyValue in $kv) {
        if ($Assert.HasFieldValue($keyValue, 'properties.value').Result -and [PSRule.Rules.Azure.Runtime.Helper]::UsesSecretPlaceholder($keyValue.properties.value)) {
            $Assert.Fail().ReasonFrom('properties.value', $LocalizedData.KeyValueShouldNotContainSecrets, $keyValue.Name)
        }
        else {
            $Assert.Pass()
        }
    }
}

#endregion Rules

#region Helper functions

function global:IsAppConfigStandardSKU {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        $Assert.HasFieldValue($TargetObject, 'sku.name', 'Standard').Result    
    }   
}

#endregion Helper functions

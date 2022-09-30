# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for App Configuration
#

#region Rules

# Synopsis: Ensure app configuration store audit diagnostic logs are enabled.
Rule 'Azure.AppConfig.AuditLogs' -Ref 'AZR-000311' -Type 'Microsoft.AppConfiguration/configurationStores' -Tag @{ release = 'GA'; ruleSet = '2022_09' } {
    
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
Rule 'Azure.AppConfig.GeoReplica' -Ref 'AZR-000312' -Type 'Microsoft.AppConfiguration/configurationStores' -If { IsAppConfigStandardSKU } -Tag @{ release = 'Preview'; ruleSet = '2022_09' } {
    $replicas = @(GetSubResources -ResourceType 'Microsoft.AppConfiguration/configurationStores/replicas')
    $appConfigLocation = GetNormalLocation -Location $TargetObject.Location

    if ($replicas) { 
        foreach ($replica in $replicas) {
            $replicaLocation = GetNormalLocation -Location $replica.Location
            if ($appConfigLocation -ne $replicaLocation) { $Assert.Pass() } else { $Assert.Fail($LocalizedData.ReplicaInSecondaryNotFound) }
        }
    }
    else {
        $Assert.Fail($LocalizedData.ReplicaNotFound)
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

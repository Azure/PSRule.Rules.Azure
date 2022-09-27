# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for App Configuration
#

#region Rules

# Synopsis: Ensure app configuration stores audit diagnostic logs are enabled.
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

#endregion Rules

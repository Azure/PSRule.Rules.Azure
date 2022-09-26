# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for App Configuration
#

#region Rules

# Synopsis: Ensure app configuration stores audit diagnostic logs are enabled.
Rule 'Azure.AppConfig.AuditLogs' -Ref 'AZR-000311' -Type 'Microsoft.AppConfiguration/configurationStores' -Tag @{ release = 'GA'; ruleSet = '2022_09' } {
    $diagnosticLogs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings')

    $Assert.Greater($diagnosticLogs, '.', 0).Reason($LocalizedData.DiagnosticSettingsNotConfigured)

    $logCategoryGroups = 'audit', 'allLogs'
    $joinedLogCategoryGroups = $logCategoryGroups -join ', '

    foreach ($setting in $diagnosticLogs) {
        $path = $setting._PSRule.path;
        $auditLogs = @($setting.Properties.logs | Where-Object {
            ($_.category -eq 'Audit' -or $_.categoryGroup -in $logCategoryGroups) -and $_.enabled
        })

        $Assert.Greater($auditLogs, '.', 0).ReasonFrom(
            'properties.logs',
            $LocalizedData.AutomationAccountDiagnosticSetting,
            $setting.name,
            'Audit',
            $joinedLogCategoryGroups
        ).PathPrefix($path)
    }
}

#endregion Rules

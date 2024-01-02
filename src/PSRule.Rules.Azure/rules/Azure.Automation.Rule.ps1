# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Automation Accounts
#

# Synopsis: Ensure variables are encrypted
Rule 'Azure.Automation.EncryptVariables' -Ref 'AZR-000086' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-5' } {
    $variables = GetSubResources -ResourceType 'Microsoft.Automation/automationAccounts/variables';
    if ($variables.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($var in $variables) {
        $path = $var._PSRule.path;
        $Assert.HasFieldValue($var, 'properties.isEncrypted', $True).PathPrefix($path);
    }
}

# Synopsis: Ensure webhook expiry is not longer than one year
Rule 'Azure.Automation.WebHookExpiry' -Ref 'AZR-000087' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $webhooks = GetSubResources -ResourceType 'Microsoft.Automation/automationAccounts/webhooks';
    if ($webhooks.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($webhook in $webhooks) {
        $path = $webhook._PSRule.path;
        $days = [math]::Abs([int]((Get-Date) - $webhook.properties.expiryTime).Days);
        $Assert.Less($days, '.', 365).PathPrefix("$path.properties.expiryTime");
    }
}

# Synopsis: Ensure automation account audit diagnostic logs are enabled.
Rule 'Azure.Automation.AuditLogs' -Ref 'AZR-000088' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2021_12'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'LT-4' } {
    $logCategoryGroups = 'audit', 'allLogs'
    $joinedLogCategoryGroups = $logCategoryGroups -join ', '
    $diagnostics = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.Automation/automationAccounts/providers/diagnosticSettings' |
        ForEach-Object { $_.Properties.logs |
            Where-Object { ($_.category -eq 'AuditEvent' -or $_.categoryGroup -in $logCategoryGroups) -and $_.enabled }
        })

    $Assert.Greater($diagnostics, '.', 0).Reason(
        $LocalizedData.AutomationAccountAuditDiagnosticSetting,
        'AuditEvent',
        $joinedLogCategoryGroups
    ).PathPrefix('resources')
}

# Synopsis: Ensure automation account platform diagnostic logs are enabled.
Rule 'Azure.Automation.PlatformLogs' -Ref 'AZR-000089' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2021_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $configurationLogCategoriesList = $Configuration.GetStringValues('AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST');

    if ($configurationLogCategoriesList.Length -eq 0) {
        return $Assert.Pass();
    }

    $diagnosticLogs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.Automation/automationAccounts/providers/diagnosticSettings');

    $Assert.Greater($diagnosticLogs, '.', 0).Reason($LocalizedData.DiagnosticSettingsNotConfigured);

    $availableLogCategories = @{
        Logs    = @(
            'JobLogs',
            'JobStreams',
            'DscNodeStatus'
        )
        Metrics = @(
            'AllMetrics'
        )
    };

    $configurationLogCategories = @($configurationLogCategoriesList | Where-Object {
            $_ -in $availableLogCategories.Logs
        });

    $configurationMetricCategories = @($configurationLogCategoriesList | Where-Object {
            $_ -in $availableLogCategories.Metrics
        });

    $logCategoriesNeeded = [System.Math]::Min(
        $configurationLogCategories.Length, 
        $availableLogCategories.Logs.Length
    );

    $metricCategoriesNeeded = [System.Math]::Min(
        $configurationMetricCategories.Length, 
        $availableLogCategories.Metrics.Length
    );

    $logCategoriesJoinedString = $configurationLogCategoriesList -join ', ';

    foreach ($setting in $diagnosticLogs) {
        $path = $setting._PSRule.path;
        $allLogs = @($setting.Properties.logs | Where-Object {
                $_.enabled -and $_.categoryGroup -eq 'allLogs'
            });

        $platformLogs = @($setting.Properties.logs | Where-Object {
                $_.enabled -and
                $_.category -in $configurationLogCategories -and
                $_.category -in $availableLogCategories.Logs
            });

        $metricLogs = @($setting.Properties.metrics | Where-Object {
                $_.enabled -and 
                $_.category -in $configurationMetricCategories -and
                $_.category -in $availableLogCategories.Metrics
            });

        $platformLogsEnabled = ($Assert.HasFieldValue($platformLogs, 'Length', $logCategoriesNeeded).Result -or 
            $Assert.Greater($allLogs, 'Length', 0).Result) -and 
        $Assert.HasFieldValue($metricLogs, 'Length', $metricCategoriesNeeded).Result;

        $Assert.Create(
            'properties.logs',
            $platformLogsEnabled,
            $LocalizedData.AutomationAccountDiagnosticSetting,
            $setting.name,
            $logCategoriesJoinedString,
            'allLogs'
        ).PathPrefix($path);
    }

} -Configure @{
    AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST = @(
        'JobLogs',
        'JobStreams',
        'DscNodeStatus',
        'AllMetrics'
    )
}

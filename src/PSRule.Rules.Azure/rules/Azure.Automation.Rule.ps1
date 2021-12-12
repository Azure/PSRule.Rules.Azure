# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Automation Accounts
#

# Synopsis: Ensure variables are encrypted
Rule 'Azure.Automation.EncryptVariables' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $variables = GetSubResources -ResourceType 'Microsoft.Automation/automationAccounts/variables';
    if ($variables.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($var in $variables) {
        $Assert.HasFieldValue($var, 'properties.isEncrypted', $True);
    }
}

# Synopsis: Ensure webhook expiry is not longer than one year
Rule 'Azure.Automation.WebHookExpiry' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $webhooks = GetSubResources -ResourceType 'Microsoft.Automation/automationAccounts/webhooks';
    if ($webhooks.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($webhook in $webhooks) {
        $days = [math]::Abs([int]((Get-Date) - $webhook.properties.expiryTime).Days)
        $Assert.Less($days, '.', 365);
    }
}

# Synopsis: Ensure automation account audit diagnostic logs are enabled.
Rule 'Azure.Automation.AuditLogs' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2021_12'; } {
    $diagnosticLogs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.Automation/automationAccounts/providers/diagnosticSettings');

    $Assert.Greater($diagnosticLogs, '.', 0).Reason($LocalizedData.DiagnosticSettingsNotConfigured);

    $logCategoryGroups = 'audit', 'allLogs';
    $joinedLogCategoryGroups = $logCategoryGroups -join ', ';

    foreach ($setting in $diagnosticLogs) {
        $auditLogs = $setting.Properties.logs | Where-Object {
            ($_.category -eq 'AuditEvent' -or ($_.categoryGroup -in $logCategoryGroups)) -and $_.enabled
        }

        $Assert.Greater($auditLogs, '.', 0).Reason(
            $LocalizedData.AutomationAccountDiagnosticSetting, 
            $setting.name, 
            'AuditEvent', 
            $joinedLogCategoryGroups
        );
    }
}

# Synopsis: Ensure automation account platform diagnostic logs are enabled.
Rule 'Azure.Automation.PlatformLogs' -Type 'Microsoft.Automation/automationAccounts' -Tag @{ release = 'GA'; ruleSet = '2021_12'; } {
    $configurationLogCategoriesList = $Configuration.GetStringValues('AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATAGORIES');

    if ($configurationLogCategoriesList.Length -eq 0) {
        return $Assert.Pass();
    }

    $diagnosticLogs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.Automation/automationAccounts/providers/diagnosticSettings');

    $Assert.Greater($diagnosticLogs, '.', 0).Reason($LocalizedData.DiagnosticSettingsNotConfigured);

    $availableLogCategories = @{
        Logs = @(
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
                                $Assert.Greater($allLogs, '.', 0).Result) -and 
                               $Assert.HasFieldValue($metricLogs, 'Length', $metricCategoriesNeeded).Result;

        $Assert.Create(
            $platformLogsEnabled, 
            $LocalizedData.AutomationAccountDiagnosticSetting, 
            $setting.name, 
            $logCategoriesJoinedString,
            'allLogs'
        );
    }

} -Configure @{
    AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATAGORIES = @(
        'JobLogs',
        'JobStreams',
        'DscNodeStatus',
        'AllMetrics'
    )
}
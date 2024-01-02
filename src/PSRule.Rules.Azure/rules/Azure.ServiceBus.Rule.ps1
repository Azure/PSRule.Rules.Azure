# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Service Bus
#

#region Rules

# Synopsis: Regularly remove unused resources to reduce costs.
Rule 'Azure.ServiceBus.Usage' -Ref 'AZR-000177' -Type 'Microsoft.ServiceBus/namespaces' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2022_03'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    $items = @(GetSubResources -ResourceType 'Microsoft.ServiceBus/namespaces/topics', 'Microsoft.ServiceBus/namespaces/queues');
    $Assert.GreaterOrEqual($items, '.', 1);
}

# Synopsis: Enforce namespaces to require that clients send and receive data with TLS 1.2 version.
Rule 'Azure.ServiceBus.MinTLS' -Ref 'AZR-000315' -Type 'Microsoft.ServiceBus/namespaces' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    $Assert.HasFieldValue($TargetObject, 'Properties.minimumTlsVersion', '1.2').Reason($LocalizedData.ServiceBusMinTLS, $PSRule.TargetName)
}

# Synopsis: Ensure namespaces audit diagnostic logs are enabled.
Rule 'Azure.ServiceBus.AuditLogs' -Ref 'AZR-000358' -Type 'Microsoft.ServiceBus/namespaces' -With 'Azure.ServiceBus.IsPremium' -Tag @{ release = 'GA'; ruleSet = '2023_03'; 'Azure.WAF/pillar' = 'Security'; } {
    $logCategoryGroups = 'audit', 'allLogs'
    $joinedLogCategoryGroups = $logCategoryGroups -join ', '
    $diagnostics = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings' |
        ForEach-Object { $_.Properties.logs |
            Where-Object { ($_.category -eq 'RuntimeAuditLogs' -or $_.categoryGroup -in $logCategoryGroups) -and $_.enabled }
        } )
    
    $Assert.GreaterOrEqual($diagnostics, '.', 1).Reason(
        $LocalizedData.ServiceBusAuditDiagnosticSetting,
        'RuntimeAuditLogs',
        $joinedLogCategoryGroups
    ).PathPrefix('resources')
}

#endregion Rules

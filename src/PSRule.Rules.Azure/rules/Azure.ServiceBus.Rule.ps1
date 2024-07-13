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

# Synopsis: Consider replication for namespaces to ensure resiliency to region outages.
Rule 'Azure.ServiceBus.GeoReplica' -Ref 'AZR-000444' -Type 'Microsoft.ServiceBus/namespaces' -Tag @{ release = 'preview'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    # Geo-replication is only available for the Premium SKU.
    $Assert.HasFieldValue($TargetObject, 'sku.name', 'Premuium')

    $locations = $TargetObject.properties.geoDataReplication.locations
    
    $Assert.HasFieldValue($locations[0], 'roleType', 'Primary')
    $Assert.HasFieldValue($locations[1], 'roleType', 'Secondary')
}

#endregion Rules

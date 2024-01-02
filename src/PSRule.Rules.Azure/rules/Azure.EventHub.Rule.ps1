# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Event Hub
#

#region Rules

# Synopsis: Regularly remove unused resources to reduce costs.
Rule 'Azure.EventHub.Usage' -Ref 'AZR-000101' -Type 'Microsoft.EventHub/namespaces' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2022_03'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    $items = @(GetSubResources -ResourceType 'Microsoft.EventHub/namespaces/eventhubs');
    $Assert.GreaterOrEqual($items, '.', 1);
}

#endregion Rules

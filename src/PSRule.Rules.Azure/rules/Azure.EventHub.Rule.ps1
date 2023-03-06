# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Event Hub
#

#region Rules

# Synopsis: Regularly remove unused resources to reduce costs.
Rule 'Azure.EventHub.Usage' -Ref 'AZR-000101' -Type 'Microsoft.EventHub/namespaces' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2022_03'; } {
    $items = @(GetSubResources -ResourceType 'Microsoft.EventHub/namespaces/eventhubs');
    $Assert.GreaterOrEqual($items, '.', 1);
}

# Synopsis: Event Hubs namespaces should reject TLS versions older than 1.2.
Rule 'Azure.EventHub.MinTLS' -Ref 'AZR-000356' -Type 'Microsoft.EventHub/namespaces' -Tag @{ release = 'GA'; ruleSet = '2023_03'; } {
    '1.2' | global:MinimumTLSVersion
}

#endregion Rules

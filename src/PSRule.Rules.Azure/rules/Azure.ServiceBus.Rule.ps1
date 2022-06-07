# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Service Bus
#

#region Rules

# Synopsis: Regularly remove unused resources to reduce costs.
Rule 'Azure.ServiceBus.Usage' -Ref 'AZR-000177' -Type 'Microsoft.ServiceBus/namespaces' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2022_03'; } {
    $items = @(GetSubResources -ResourceType 'Microsoft.ServiceBus/namespaces/topics', 'Microsoft.ServiceBus/namespaces/queues');
    $Assert.GreaterOrEqual($items, '.', 1);
}

#endregion Rules

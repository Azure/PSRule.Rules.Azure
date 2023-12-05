# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Data Explorer
#

#region Rules

# Synopsis: Regularly remove unused resources to reduce costs.
Rule 'Azure.ADX.Usage' -Ref 'AZR-000011' -Type 'Microsoft.Kusto/clusters' -If { IsExport } -With 'Azure.ADX.IsClusterRunning' -Tag @{ release = 'GA'; ruleSet = '2022_03'; 'Azure.WAF/pillar' = 'Cost Optimization'; method = 'in-flight'; } {
    $items = @(GetSubResources -ResourceType 'Microsoft.Kusto/clusters/databases');
    $Assert.GreaterOrEqual($items, '.', 1);
}

#endregion Rules

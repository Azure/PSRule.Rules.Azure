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

# Synopsis: Access to the namespace endpoints should be restricted to only allowed sources.
Rule 'Azure.EventHub.Firewall' -Ref 'AZR-000422' -Type 'Microsoft.EventHub/namespaces', 'Microsoft.EventHub/namespaces/networkRuleSets' -If { Test-IsNoBasicTier } -Tag @{ release = 'GA'; ruleSet = '2024_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'NS-1', 'NS-2' } {
    $firewall = @(GetSubResources -ResourceType 'Microsoft.EventHub/namespaces/networkRuleSets')
    AnyOf {
        $Assert.HasFieldValue($TargetObject, 'properties.publicNetworkAccess', 'Disabled')
        $Assert.HasFieldValue($firewall[0], 'properties.publicNetworkAccess', 'Disabled')
        $Assert.HasFieldValue($firewall[0], 'properties.defaultAction', 'Deny')
    }
}

#endregion Rules

#region Helper functions

function global:Test-IsNoBasicTier {
    [CmdletBinding()]
    param ()
    -not $Assert.HasFieldValue($TargetObject, 'sku.tier', 'Basic').Result
}

#endregion Helper functions

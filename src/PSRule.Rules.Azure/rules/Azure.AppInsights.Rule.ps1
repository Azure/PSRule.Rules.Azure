# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Application Insights
#

#region Rules

# Synopsis: Application Insights resources without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.AppInsights.Naming' -Ref 'AZR-000485' -Type 'Microsoft.Insights/components' -If { $Configuration['AZURE_APP_INSIGHTS_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_APP_INSIGHTS_NAME_FORMAT, $True);
}

#endregion Rules

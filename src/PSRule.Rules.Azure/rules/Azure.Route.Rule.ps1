# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Route tables
#

# Synopsis: Use standard route table names.
Rule 'Azure.Route.Naming' -Ref 'AZR-000468' -Type 'Microsoft.Network/routeTables' -If { $Configuration['AZURE_ROUTE_TABLE_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_ROUTE_TABLE_NAME_FORMAT, $True);
}

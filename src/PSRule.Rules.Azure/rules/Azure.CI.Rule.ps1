# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Container Instances
#

#region Rules

# Synopsis: Container instances without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.CI.Naming' -Ref 'AZR-000505' -Type 'Microsoft.ContainerInstance/containerGroups' -If { $Configuration['AZURE_CONTAINER_INSTANCE_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_CONTAINER_INSTANCE_NAME_FORMAT, $True);
}

#endregion Rules

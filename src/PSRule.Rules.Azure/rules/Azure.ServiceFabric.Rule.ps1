# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Service Fabric
#

#region Naming rules

# Synopsis: Service Fabric clusters without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.ServiceFabric.Naming' -Ref 'AZR-000506' -Type 'Microsoft.ServiceFabric/clusters' -If { $Configuration['AZURE_SERVICE_FABRIC_CLUSTER_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_SERVICE_FABRIC_CLUSTER_NAME_FORMAT, $True);
}

# Synopsis: Service Fabric managed clusters without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.ServiceFabric.ManagedNaming' -Ref 'AZR-000507' -Type 'Microsoft.ServiceFabric/managedClusters' -If { $Configuration['AZURE_SERVICE_FABRIC_MANAGED_CLUSTER_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_SERVICE_FABRIC_MANAGED_CLUSTER_NAME_FORMAT, $True);
}

#endregion Naming rules

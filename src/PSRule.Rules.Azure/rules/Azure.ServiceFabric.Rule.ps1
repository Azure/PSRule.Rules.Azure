# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Service Fabric
#

# Synopsis: Use Azure Active Directory (AAD) client authentication for Service Fabric clusters.
Rule 'Azure.ServiceFabric.AAD' -Ref 'AZR-000179' -Type 'Microsoft.ServiceFabric/clusters' -Tag @{ release = 'GA'; ruleSet = '2021_03'; 'Azure.WAF/pillar' = 'Security'; 'Azure.ASB.v3/control' = @('IM-1','IM-3') } {
    $Assert.HasFieldValue($TargetObject, 'properties.azureActiveDirectory.tenantId');
}

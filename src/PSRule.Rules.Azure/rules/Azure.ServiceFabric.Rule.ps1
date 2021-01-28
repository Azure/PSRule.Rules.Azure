# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Service Fabric
#

# Synopsis: Use Azure Active Directory (AAD) client authentication for Service Fabric clusters.
Rule 'Azure.ServiceFabric.AAD' -Type 'Microsoft.ServiceFabric/clusters' -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.azureActiveDirectory.tenantId');
}

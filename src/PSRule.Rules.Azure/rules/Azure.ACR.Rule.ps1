# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Container Registry
#

# Synopsis: Use RBAC for delegating access to ACR instead of the registry admin user
Rule 'Azure.ACR.AdminUser' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.adminUserEnabled', $False)
}

# Synopsis: ACR should use the Premium or Standard SKU for production deployments
Rule 'Azure.ACR.MinSku' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.In($TargetObject, 'Sku.tier', @('Premium', 'Standard'))
}

# Synopsis: Use ACR naming requirements
Rule 'Azure.ACR.Name' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcontainerregistry

    # Between 5 and 50 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 5)
    $Assert.LessOrEqual($TargetObject, 'Name', 50)

    # Alphanumerics
    $Assert.Match($TargetObject, 'Name', '^[a-zA-Z0-9]*$')
}

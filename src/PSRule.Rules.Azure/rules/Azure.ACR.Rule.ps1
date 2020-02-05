# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Container Registry
#

# Synopsis: Use RBAC for delegating access to ACR instead of the registry admin user
Rule 'Azure.ACR.AdminUser' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.adminUserEnabled', $False)
}

# Synopsis: ACR should use the Premium or Standard SKU for production deployments
Rule 'Azure.ACR.MinSku' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA' } {
    Within 'Sku.tier' 'Premium', 'Standard'
}

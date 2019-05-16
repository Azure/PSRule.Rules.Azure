#
# Validation rules for Azure Container Registry
#

# Description: Use RBAC for delegating access to ACR instead of the registry admin user
Rule 'Azure.ACR.AdminUser' -If { ResourceType 'Microsoft.ContainerRegistry/registries' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    $TargetObject.Properties.adminUserEnabled -eq $False
}

# Description: ACR should use the Premium or Standard SKU for production deployments
Rule 'Azure.ACR.MinSku' -If { ResourceType 'Microsoft.ContainerRegistry/registries' } -Tag @{ severity = 'Important'; category = 'Performance' } {
    Within 'Sku.tier' -AllowedValue 'Premium', 'Standard'
}

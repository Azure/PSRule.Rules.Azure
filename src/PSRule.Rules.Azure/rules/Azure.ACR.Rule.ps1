#
# Validation rules for Azure Container Registry
#

# Synopsis: Use RBAC for delegating access to ACR instead of the registry admin user
Rule 'Azure.ACR.AdminUser' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; severity = 'Critical'; category = 'Security configuration' } {
    $TargetObject.Properties.adminUserEnabled -eq $False
}

# Synopsis: ACR should use the Premium or Standard SKU for production deployments
Rule 'Azure.ACR.MinSku' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; severity = 'Important'; category = 'Performance' } {
    Within 'Sku.tier' -AllowedValue 'Premium', 'Standard'
}

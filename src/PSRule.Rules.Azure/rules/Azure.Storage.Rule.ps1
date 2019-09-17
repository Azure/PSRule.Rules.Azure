#
# Validation rules for Azure Storage Accounts
#

# Synopsis: Storage accounts not using GRS may be at risk
Rule 'Azure.Storage.UseReplication' -If { ResourceType 'Microsoft.Storage/storageAccounts' } -Tag @{ severity = 'Single point of failure'; category = 'Reliability' } {
    Within 'sku.name' 'Standard_GRS', 'Standard_RAGRS'
}

# Synopsis: Storage accounts should only accept secure traffic
Rule 'Azure.Storage.SecureTransferRequired' -If { ResourceType 'Microsoft.Storage/storageAccounts' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    $TargetObject.Properties.supportsHttpsTrafficOnly -eq $True
}

# Synopsis: Storage Service Encryption (SSE) should be enabled
Rule 'Azure.Storage.UseEncryption' -If { ResourceType 'Microsoft.Storage/storageAccounts' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    Within 'Properties.encryption.services.blob.enabled' $True
    Within 'Properties.encryption.services.file.enabled' $True
}

# Synopsis: Enable soft delete on Storage Accounts
Rule 'Azure.Storage.SoftDelete' -If { ResourceType 'Microsoft.Storage/storageAccounts' } -Tag @{ severity = 'Important'; category = 'Data recovery' } {
    $serviceProperties = $TargetObject.resources | Where-Object -FilterScript {
        $_.ResourceType -eq 'Microsoft.Storage/storageAccounts/blobServices'
    }
    $serviceProperties.properties.deleteRetentionPolicy.enabled -eq $True
}

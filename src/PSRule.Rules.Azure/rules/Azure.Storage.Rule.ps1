#
# Validation rules for Azure Storage Accounts
#

# Description: Use GRS for storage accounts that don't store disks
Rule 'Azure.Storage.UseReplication' -If { ResourceType 'Microsoft.Storage/storageAccounts' } -Tag @{ severity = 'Single point of failure'; category = 'Reliability' } {
    Hint 'Storage accounts not using GRS may be at risk'

    $TargetObject.sku.name -eq 'Standard_GRS'
}

# Description: Configure storage accounts to only access encrypted traffic i.e. HTTPS/SMB
Rule 'Azure.Storage.SecureTransferRequired' -If { ResourceType 'Microsoft.Storage/storageAccounts' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    Hint 'Storage accounts should only allow secure traffic'

    $TargetObject.Properties.supportsHttpsTrafficOnly
}

# Description: Storage Service Encryption (SSE) should be enabled
Rule 'Azure.Storage.UseEncryption' -If { ResourceType 'Microsoft.Storage/storageAccounts' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    Hint 'Storage accounts should have encryption enabled'

    ($Null -ne $TargetObject.Properties.encryption) -and
    ($Null -ne $TargetObject.Properties.encryption.services.blob) -and
    ($Null -ne $TargetObject.Properties.encryption.services.file) -and
    ($TargetObject.Properties.encryption.services.blob.enabled -and $TargetObject.Properties.encryption.services.file.enabled)
}

# Description: Soft delete is enabled on Storage Accounts
Rule 'Azure.Storage.SoftDelete' -If { ResourceType 'Microsoft.Storage/storageAccounts' } -Tag @{ severity = 'Important'; category = 'Data recovery' } {
    $serviceProperties = $TargetObject.resources | Where-Object -FilterScript {
        $_.ResourceType -eq 'serviceProperties'
    }

    $serviceProperties.DeleteRetentionPolicy.Enabled
}

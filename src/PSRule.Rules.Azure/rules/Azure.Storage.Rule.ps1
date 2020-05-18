# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Storage Accounts
#

# Synopsis: Storage accounts not using GRS may be at risk
Rule 'Azure.Storage.UseReplication' -Type 'Microsoft.Storage/storageAccounts' -If { !(IsCloudShell) } -Tag @{ release = 'GA' } {
    Within 'sku.name' 'Standard_GRS', 'Standard_RAGRS'
}

# Synopsis: Storage accounts should only accept secure traffic
Rule 'Azure.Storage.SecureTransfer' -Type 'Microsoft.Storage/storageAccounts' -Tag @{ release = 'GA' } {
    $TargetObject.Properties.supportsHttpsTrafficOnly -eq $True
}

# Synopsis: Storage Service Encryption (SSE) should be enabled
Rule 'Azure.Storage.UseEncryption' -Type 'Microsoft.Storage/storageAccounts' -Tag @{ release = 'GA' } {
    Within 'Properties.encryption.services.blob.enabled' $True
    Within 'Properties.encryption.services.file.enabled' $True
}

# Synopsis: Enable soft delete on Storage Accounts
Rule 'Azure.Storage.SoftDelete' -Type 'Microsoft.Storage/storageAccounts' -If { !(IsCloudShell) } -Tag @{ release = 'GA' } {
    $serviceProperties = GetSubResources -ResourceType 'Microsoft.Storage/storageAccounts/blobServices'
    $serviceProperties.properties.deleteRetentionPolicy.enabled -eq $True
}

# Synopsis: Avoid using Blob or Container access type
Rule 'Azure.Storage.BlobAccessType' -Type 'Microsoft.Storage/storageAccounts', 'Microsoft.Storage/storageAccounts/blobServices/containers' -Tag @{ release = 'GA' } {
    $containers = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Storage/storageAccounts') {
        $containers = @(GetSubResources -ResourceType 'Microsoft.Storage/storageAccounts/blobServices/containers');
    }
    if ($containers.Length -eq 0) {
        return $True;
    }
    foreach ($container in $containers) {
        $Assert.
            HasFieldValue($container, 'Properties.publicAccess', 'None').
            WithReason(($LocalizedData.PublicAccessStorageContainer -f $container.name, $container.Properties.publicAccess), $True);
    }
}

# Synopsis: Use Storage naming requirements
Rule 'Azure.Storage.Name' -Type 'Microsoft.Storage/storageAccounts' -Tag @{ release = 'GA' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage

    # Between 3 and 24 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 3)
    $Assert.LessOrEqual($TargetObject, 'Name', 24)

    # Lowercase letters and numbers
    Match 'Name' '^[a-z0-9]{3,24}$' -CaseSensitive
}

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Storage Accounts
#

# Synopsis: Storage Accounts not using geo-replicated storage (GRS) may be at risk.
Rule 'Azure.Storage.UseReplication' -Type 'Microsoft.Storage/storageAccounts' -If { (ShouldStorageReplicate) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.In($TargetObject, 'sku.name', @(
        'Standard_GRS'
        'Standard_RAGRS'
        'Standard_GZRS'
        'Standard_RAGZRS'
    ));
}

# Synopsis: Storage accounts should only accept secure traffic
Rule 'Azure.Storage.SecureTransfer' -Type 'Microsoft.Storage/storageAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.supportsHttpsTrafficOnly', $True);
}

# Synopsis: Enable soft delete on Storage Accounts
Rule 'Azure.Storage.SoftDelete' -Type 'Microsoft.Storage/storageAccounts', 'Microsoft.Storage/storageAccounts/blobServices' -If { !(IsCloudShell) -and !(IsHnsStorage) -and !(IsFileStorage) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $services = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Storage/storageAccounts') {
        $services = @(GetSubResources -ResourceType 'Microsoft.Storage/storageAccounts/blobServices');
    }
    if ($services.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Storage/storageAccounts/blobServices');
    }
    foreach ($service in $services) {
        $Assert.HasFieldValue($service, 'properties.deleteRetentionPolicy.enabled', $True);
    }
}

# Synopsis: Disallow blob containers with public access types.
Rule 'Azure.Storage.BlobPublicAccess' -Type 'Microsoft.Storage/storageAccounts' -If { !(IsFileStorage) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.allowBlobPublicAccess', $False);
}

# Synopsis: Use containers configured with a private access type that requires authorization.
Rule 'Azure.Storage.BlobAccessType' -Type 'Microsoft.Storage/storageAccounts', 'Microsoft.Storage/storageAccounts/blobServices/containers' -If { !(IsFileStorage) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $containers = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Storage/storageAccounts') {
        $containers = @(GetSubResources -ResourceType 'Microsoft.Storage/storageAccounts/blobServices/containers');
    }
    if ($containers.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($container in $containers) {
        $Assert.HasDefaultValue($container, 'Properties.publicAccess', 'None').
            Reason($LocalizedData.PublicAccessStorageContainer, $container.name, $container.Properties.publicAccess);
    }
}

# Synopsis: Storage Accounts should reject TLS versions older than 1.2.
Rule 'Azure.Storage.MinTLS' -Type 'Microsoft.Storage/storageAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.minimumTlsVersion', 'TLS1_2');
}

# Synopsis: Use Storage naming requirements
Rule 'Azure.Storage.Name' -Type 'Microsoft.Storage/storageAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage

    # Between 3 and 24 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 3)
    $Assert.LessOrEqual($TargetObject, 'Name', 24)

    # Lowercase letters and numbers
    Match 'Name' '^[a-z0-9]{3,24}$' -CaseSensitive
}

#region Helper functions

function global:ShouldStorageReplicate {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return (IsStandardStorage) -and
            !(IsCloudShell) -and
            !(IsFunctionStorage) -and
            !(IsMonitorStorage) -and
            !(IsLargeFileSharesEnabled)
    }
}

function global:IsStandardStorage {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Storage/storageAccounts') {
            return $False;
        }
        return $TargetObject.sku.name -like 'Standard_*';
    }
}

function global:IsCloudShell {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Storage/storageAccounts') {
            return $False;
        }
        return $TargetObject.Tags.'ms-resource-usage' -eq 'azure-cloud-shell';
    }
}

function global:IsFunctionStorage {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Storage/storageAccounts') {
            return $False;
        }
        return $TargetObject.Tags.'resource-usage' -eq 'azure-functions';
    }
}

function global:IsMonitorStorage {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Storage/storageAccounts') {
            return $False;
        }
        return $TargetObject.Tags.'resource-usage' -eq 'azure-monitor';
    }
}

function global:IsFileStorage {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Storage/storageAccounts') {
            return $False;
        }
        return $Assert.HasFieldValue($TargetObject, 'Kind', 'FileStorage').Result;
    }
}

# Some features are not supported with hierarchical namespace
function global:IsHnsStorage {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Storage/storageAccounts') {
            return $False;
        }
        return $Assert.HasFieldValue($TargetObject, 'Properties.isHnsEnabled', $True).Result;
    }
}

function global:IsLargeFileSharesEnabled {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Storage/storageAccounts') {
            return $False;
        }
        return $Assert.HasFieldValue($TargetObject, 'Properties.largeFileSharesState', 'Enabled').Result;
    }
}

#endregion Helper functions

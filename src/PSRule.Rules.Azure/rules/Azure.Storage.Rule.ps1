# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Storage Accounts
#

# Synopsis: Storage Accounts not using geo-replicated storage (GRS) may be at risk.
Rule 'Azure.Storage.UseReplication' -Ref 'AZR-000195' -Type 'Microsoft.Storage/storageAccounts' -If { (ShouldStorageReplicate) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.In($TargetObject, 'sku.name', @(
            'Standard_GRS'
            'Standard_RAGRS'
            'Standard_GZRS'
            'Standard_RAGZRS'
        ));
}

# Synopsis: Enable soft delete on Storage Accounts
Rule 'Azure.Storage.SoftDelete' -Ref 'AZR-000197' -Type 'Microsoft.Storage/storageAccounts', 'Microsoft.Storage/storageAccounts/blobServices' -If { !(IsCloudShell) -and !(IsHnsStorage) -and !(IsFileStorage) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
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

# Synopsis: Use containers configured with a private access type that requires authorization.
Rule 'Azure.Storage.BlobAccessType' -Ref 'AZR-000199' -Type 'Microsoft.Storage/storageAccounts', 'Microsoft.Storage/storageAccounts/blobServices/containers' -If { !(IsFileStorage) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
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

# Synopsis: Use Storage naming requirements
Rule 'Azure.Storage.Name' -Ref 'AZR-000201' -Type 'Microsoft.Storage/storageAccounts' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage

    # Between 3 and 24 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 3)
    $Assert.LessOrEqual($TargetObject, 'Name', 24)

    # Lowercase letters and numbers
    Match 'Name' '^[a-z0-9]{3,24}$' -CaseSensitive
}

# Synopsis: Enable soft delete on Storage Accounts file shares.
Rule 'Azure.Storage.FileShareSoftDelete' -Ref 'AZR-000298' -Type 'Microsoft.Storage/storageAccounts', 'Microsoft.Storage/storageAccounts/fileServices' -If { (IsFileStorage) -and !(IsCloudShell) -and !(IsHnsStorage) } -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $services = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Storage/storageAccounts') {
        $services = @(GetSubResources -ResourceType 'Microsoft.Storage/storageAccounts/fileServices');
    }

    if ($services.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Storage/storageAccounts/fileServices');
    }

    foreach ($service in $services) {
        $Assert.HasFieldValue($service, 'properties.shareDeleteRetentionPolicy.enabled', $True);
        $Assert.HasFieldValue($service, 'properties.shareDeleteRetentionPolicy.days', 7);
    }
}

# Synopsis: Enable container soft delete on Storage Accounts.
Rule 'Azure.Storage.ContainerSoftDelete' -Ref 'AZR-000289' -Type 'Microsoft.Storage/storageAccounts', 'Microsoft.Storage/storageAccounts/blobServices' -If { !(IsCloudShell) -and !(IsHnsStorage) -and !(IsFileStorage) } -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $services = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Storage/storageAccounts') {
        $services = @(GetSubResources -ResourceType 'Microsoft.Storage/storageAccounts/blobServices');
    }
    if ($services.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Storage/storageAccounts/blobServices');
    }
    foreach ($service in $services) {
        $Assert.HasFieldValue($service, 'properties.containerDeleteRetentionPolicy.enabled', $True);
        $Assert.GreaterOrEqual($service, 'properties.containerDeleteRetentionPolicy.days', 1);
    }
}

# Synopsis: Enable Malware Scanning in Microsoft Defender for Storage.
Rule 'Azure.Storage.DefenderCloud.MalwareScan' -Ref 'AZR-000384' -Type 'Microsoft.Storage/storageAccounts' -If { IsPublicNetworkAccessEnabled } -Tag @{ release = 'Preview'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-2', 'LT-1' } {
    $malwareDisabled = @(GetSubResources -ResourceType 'Microsoft.Security/DefenderForStorageSettings' |
        Where-Object { $_.properties.malwareScanning.onUpload.isEnabled -eq $False })
    $Assert.Count($malwareDisabled, '.', 0).Reason($LocalizedData.ResStorageMalwareScanning, $PSRule.TargetName)
}

# Synopsis: Enable sensitive data threat detection in Microsoft Defender for Storage.
Rule 'Azure.Storage.DefenderCloud.SensitiveData' -Ref 'AZR-000391' -Type 'Microsoft.Storage/storageAccounts' -If { IsPublicNetworkAccessEnabled } -Tag @{ release = 'Preview'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-2', 'LT-1' } {
    $sensitiveDisabled = @(GetSubResources -ResourceType 'Microsoft.Security/DefenderForStorageSettings' |
        Where-Object { $_.properties.sensitiveDataDiscovery.isEnabled -eq $False })
    $Assert.Count($sensitiveDisabled, '.', 0).Reason($LocalizedData.ResStorageSensitiveDataThreatDetection, $PSRule.TargetName)
}

# Synopsis: Enable Microsoft Defender for Storage for storage accounts.
Rule 'Azure.Storage.DefenderCloud' -Ref 'AZR-000386' -Type 'Microsoft.Storage/storageAccounts' -If { $Configuration.AZURE_STORAGE_DEFENDER_PER_ACCOUNT -eq $True } -Tag @{ release = 'GA'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-2', 'LT-1' } {
    $defender = @(GetSubResources -ResourceType 'Microsoft.Security/DefenderForStorageSettings' |
    Where-Object { $_.properties.isEnabled -eq $True })
    $Assert.GreaterOrEqual($defender, '.', 1).Reason($LocalizedData.SubResourceNotFound, 'Microsoft.Security/DefenderForStorageSettings')
} -Configure @{ AZURE_STORAGE_DEFENDER_PER_ACCOUNT = $False }

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

function global:IsPublicNetworkAccessEnabled {
    [CmdletBinding()]
    param ()
    process {
        $Assert.HasDefaultValue($TargetObject, 'properties.publicNetworkAccess', 'Enabled').Result
    }
}

#endregion Helper functions

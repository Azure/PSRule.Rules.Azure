# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Determines if the object is a managed resource group created by Azure
function global:Azure_IsManagedRG {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Resources/resourceGroups') {
            return $False;
        }

        # Check for managed RG names
        return (
            $PSRule.TargetName -eq 'NetworkWatcherRG' -or
            $PSRule.TargetName -like 'AzureBackupRG_*' -or
            $PSRule.TargetName -like 'DefaultResourceGroup-*' -or
            $PSRule.TargetName -like 'cloud-shell-storage-*' -or
            $PSRule.TargetName -like 'MC_*'
        )
    }
}

# Determines if the object is a managed load balancer created by Azure
function global:Azure_IsManagedLB {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Network/loadBalancers') {
            return $False;
        }

        # Check for managed load balancer names
        return (
            $PSRule.TargetName -like 'kubernetes*'
        )
    }
}

# Determines if the object is a managed storage account created by Azure
function global:Azure_IsManagedStorage {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Storage/storageAccounts') {
            return $False;
        }
        # Check for managed storage accounts
        if ($Assert.HasFieldValue($TargetObject, 'Tags.ms-resource-usage', 'azure-cloud-shell').Result) {
            return $True;
        }
        return $False;
    }
}

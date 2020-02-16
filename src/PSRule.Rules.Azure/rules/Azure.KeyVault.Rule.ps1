# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Key Vault
#

# Synopsis: Enable Key Vault Soft Delete
Rule 'Azure.KeyVault.SoftDelete' -Type 'Microsoft.KeyVault/vaults' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enableSoftDelete', $True)
}

# Synopsis: Enable Key Vault Purge Protection
Rule 'Azure.KeyVault.PurgeProtect' -Type 'Microsoft.KeyVault/vaults' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enablePurgeProtection', $True)
}

# Synopsis: Limit access to Key Vault data
Rule 'Azure.KeyVault.AccessPolicy' -Type 'Microsoft.KeyVault/vaults', 'Microsoft.KeyVault/vaults/accessPolicies' -Tag @{ release = 'GA' } {
    Reason $LocalizedData.AccessPolicyLeastPrivilege;
    $accessPolicies = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.KeyVault/vaults') {
        $accessPolicies = @($TargetObject.Properties.accessPolicies);
    }
    if ($accessPolicies.Length -eq 0) {
        return $True;
    }
    foreach ($policy in $accessPolicies) {
        $policy.permissions.keys -notin 'All', 'Purge'
        $policy.permissions.secrets -notin 'All', 'Purge'
        $policy.permissions.certificates -notin 'All', 'Purge'
        $policy.permissions.storage -notin 'All', 'Purge'
    }
}

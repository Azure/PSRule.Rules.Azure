# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Key Vault
#

# Synopsis: Enable Key Vault Soft Delete
Rule 'Azure.KeyVault.SoftDelete' -Type 'Microsoft.KeyVault/vaults' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enableSoftDelete', $True)
}

# Synopsis: Enable Key Vault Purge Protection
Rule 'Azure.KeyVault.PurgeProtect' -Type 'Microsoft.KeyVault/vaults' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enablePurgeProtection', $True)
}

# Synopsis: Limit access to Key Vault data
Rule 'Azure.KeyVault.AccessPolicy' -Type 'Microsoft.KeyVault/vaults', 'Microsoft.KeyVault/vaults/accessPolicies' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Reason $LocalizedData.AccessPolicyLeastPrivilege;
    $accessPolicies = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.KeyVault/vaults') {
        $accessPolicies = @($TargetObject.Properties.accessPolicies);
    }
    if ($accessPolicies.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($policy in $accessPolicies) {
        $policy.permissions.keys -notin 'All', 'Purge'
        $policy.permissions.secrets -notin 'All', 'Purge'
        $policy.permissions.certificates -notin 'All', 'Purge'
        $policy.permissions.storage -notin 'All', 'Purge'
    }
}

# Synopsis: Use diagnostics to audit Key Vault access
Rule 'Azure.KeyVault.Logs' -Type 'Microsoft.KeyVault/vaults' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Reason $LocalizedData.DiagnosticSettingsNotConfigured;
    $diagnostics = @(GetSubResources -ResourceType 'microsoft.insights/diagnosticSettings', 'Microsoft.KeyVault/vaults/providers/diagnosticSettings' | Where-Object {
        $_.Properties.logs[0].category -eq 'AuditEvent'
    });
    $Null -ne $diagnostics -and $diagnostics.Length -gt 0;
    foreach ($setting in $diagnostics) {
        $Assert.HasFieldValue($setting, 'Properties.logs[0].enabled', $True);
    }
}

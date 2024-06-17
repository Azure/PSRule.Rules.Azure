# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Key Vault
#

# Synopsis: Limit access to Key Vault data
Rule 'Azure.KeyVault.AccessPolicy' -Ref 'AZR-000118' -Type 'Microsoft.KeyVault/vaults', 'Microsoft.KeyVault/vaults/accessPolicies' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
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

# Synopsis: Ensure audit diagnostics logs are enabled to audit Key Vault access.
Rule 'Azure.KeyVault.Logs' -Ref 'AZR-000119' -Type 'Microsoft.KeyVault/vaults' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = @('LT-4') } {
    $logCategoryGroups = 'audit', 'allLogs'
    $joinedLogCategoryGroups = $logCategoryGroups -join ', '
    $diagnostics = @(GetSubResources -ResourceType 'microsoft.insights/diagnosticSettings', 'Microsoft.KeyVault/vaults/providers/diagnosticSettings' |
        ForEach-Object { $_.properties.logs |
            Where-Object { ($_.category -eq 'AuditEvent' -or $_.categoryGroup -in $logCategoryGroups) -and $_.enabled }
        })
    
    $Assert.Greater($diagnostics, '.', 0).Reason(
        $LocalizedData.KeyVaultAuditDiagnosticSetting,
        'AuditEvent',
        $joinedLogCategoryGroups
    ).PathPrefix('resources')
}

# Synopsis: Key Vault names should meet naming requirements.
Rule 'Azure.KeyVault.Name' -Ref 'AZR-000120' -Type 'Microsoft.KeyVault/vaults' -Tag @{ release = 'GA'; ruleSet = '2021_03'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault

    # Between 3 and 24 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3);
    $Assert.LessOrEqual($PSRule, 'TargetName', 24);

    # Alphanumerics and hyphens
    # Start with a letter
    # End with a letter or digit
    # Can not contain consecutive hyphens
    $Assert.Match($PSRule, 'TargetName', '^[A-Za-z](-|[A-Za-z0-9])*[A-Za-z0-9]$');
}

# Synopsis: Key Vault Secret names should meet naming requirements.
Rule 'Azure.KeyVault.SecretName' -Ref 'AZR-000121' -Type 'Microsoft.KeyVault/vaults', 'Microsoft.KeyVault/vaults/secrets' -Tag @{ release = 'GA'; ruleSet = '2021_03'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault

    $secrets = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.KeyVault/vaults') {
        $secrets = @(GetSubResources -ResourceType 'Microsoft.KeyVault/vaults/secrets');
    }
    if ($secrets.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($secret in $secrets) {
        $nameParts = $secret.Name.Split('/');
        $name = $nameParts[-1];

        # Between 1 and 127 characters long
        $Assert.GreaterOrEqual($name, '.', 1);
        $Assert.LessOrEqual($name, '.', 127);

        # Alphanumerics and hyphens
        $Assert.Match($name, '.', '^[A-Za-z0-9-]{1,127}$');
    }
}

# Synopsis: Key Vault Key names should meet naming requirements.
Rule 'Azure.KeyVault.KeyName' -Ref 'AZR-000122' -Type 'Microsoft.KeyVault/vaults', 'Microsoft.KeyVault/vaults/keys' -Tag @{ release = 'GA'; ruleSet = '2021_03'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault

    $keys = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.KeyVault/vaults') {
        $keys = @(GetSubResources -ResourceType 'Microsoft.KeyVault/vaults/keys');
    }
    if ($keys.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($key in $keys) {
        $nameParts = $key.Name.Split('/');
        $name = $nameParts[-1];

        # Between 1 and 127 characters long
        $Assert.GreaterOrEqual($name, '.', 1);
        $Assert.LessOrEqual($name, '.', 127);

        # Alphanumerics and hyphens
        $Assert.Match($name, '.', '^[A-Za-z0-9-]{1,127}$');
    }
}

# Synopsis: Key Vault keys should have auto-rotation enabled.
Rule 'Azure.KeyVault.AutoRotationPolicy' -Ref 'AZR-000123' -Type 'Microsoft.KeyVault/vaults', 'Microsoft.KeyVault/vaults/keys' -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Security'; 'Azure.MCSB.v1/control' = 'IM-3' } {
    $keys = @($TargetObject);

    if ($PSRule.TargetType -eq 'Microsoft.KeyVault/vaults') {
        $keys = @(GetSubResources -ResourceType 'Microsoft.KeyVault/vaults/keys');
    }

    if ($keys.Length -eq 0) {
        return $Assert.Pass();
    }

    foreach ($key in $keys) {
        $rotationPolicy = $key.Properties.rotationPolicy;
        $autoRotateActions = @($rotationPolicy.lifetimeActions | Where-Object { $_.action.type -eq 'rotate' });

        $Assert.Greater($autoRotateActions, '.', 0).Reason(
            $LocalizedData.KeyVaultAutoRotationPolicy,
            $key.Name
        );
    }
}

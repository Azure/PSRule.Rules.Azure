---
reviewed: 2024-02-02
severity: Important
pillar: Reliability
category: RE:07 Self-preservation
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.PurgeProtect/
---

# Use Key Vault Purge Protection

## SYNOPSIS

Enable Purge Protection on Key Vaults to prevent early purge of vaults and vault items.

## DESCRIPTION

Purge Protection is a feature of Key Vault that prevents purging of vaults and vault items.
When soft delete is configured without purge protection, deleted vaults and vault items can be purged.
Purging deletes the vault and/ or vault items immediately, and is irreversible.

When purge protection is enabled, vaults and vault items can no longer be purged.
Deleted vaults and vault items will be recoverable until the configured retention period.
By default, the retention period is 90 days.

Purge protection is not enabled by default.

## RECOMMENDATION

Consider enabling purge protection on Key Vaults to enforce retention of vaults and vault items for up to 90 days.

## EXAMPLES

### Configure with Azure template

To deploy Key Vaults that pass this rule:

- Set the `properties.enablePurgeProtection` property to `true`.

For example:

```json
{
  "type": "Microsoft.KeyVault/vaults",
  "apiVersion": "2023-07-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "sku": {
      "family": "A",
      "name": "premium"
    },
    "tenantId": "[tenant().tenantId]",
    "softDeleteRetentionInDays": 90,
    "enableSoftDelete": true,
    "enablePurgeProtection": true,
    "enableRbacAuthorization": true,
    "networkAcls": {
      "defaultAction": "Deny",
      "bypass": "AzureServices"
    }
  }
}
```

### Configure with Bicep

To deploy Key Vaults that pass this rule:

- Set the `properties.enablePurgeProtection` property to `true`.

For example:

```bicep
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: tenant().tenantId
    softDeleteRetentionInDays: 90
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}
```

### Configure with Azure CLI

```bash
az keyvault update -n '<name>' -g '<resource_group>' --enable-purge-protection
```

### Configure with Azure PowerShell

```powershell
Update-AzKeyVault -ResourceGroupName '<resource_group>' -Name '<name>' -EnablePurgeProtection
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Key vaults should have deletion protection enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Key%20Vault/KeyVault_Recoverable_Audit.json)

## LINKS

- [RE:07 Self-preservation](https://learn.microsoft.com/azure/well-architected/reliability/self-preservation)
- [Azure Key Vault soft-delete overview](https://learn.microsoft.com/azure/key-vault/general/soft-delete-overview)
- [Azure Key Vault security](https://learn.microsoft.com/azure/key-vault/general/security-features)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults)

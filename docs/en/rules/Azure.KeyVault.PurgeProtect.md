---
severity: Important
pillar: Reliability
category: Data management
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
    "apiVersion": "2021-10-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "properties": {
        "sku": {
            "family": "A",
            "name": "premium"
        },
        "tenantId": "[subscription().tenantId]",
        "enableSoftDelete": true,
        "softDeleteRetentionInDays": 90,
        "enablePurgeProtection": true
    }
}
```

### Configure with Bicep

To deploy Key Vaults that pass this rule:

- Set the `properties.enablePurgeProtection` property to `true`.

For example:

```bicep
resource vault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
  }
}
```

## LINKS

- [Azure Key Vault soft-delete overview](https://docs.microsoft.com/azure/key-vault/general/soft-delete-overview)
- [Azure Key Vault security](https://docs.microsoft.com/azure/key-vault/general/security-overview#backup-and-recovery)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.keyvault/vaults)

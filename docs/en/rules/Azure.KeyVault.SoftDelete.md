---
severity: Important
pillar: Reliability
category: Data management
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.SoftDelete/
---

# Use Key Vault Soft Delete

## SYNOPSIS

Enable Soft Delete on Key Vaults to protect vaults and vault items from accidental deletion.

## DESCRIPTION

Soft Delete is a feature of Key Vault that retains Key Vaults and Key Vault items after initial deletion.
A soft deleted vault or vault item can be restored within the configured retention period.

By default, new Key Vaults created through the portal will have soft delete for 90 days configured.

Once enabled, soft delete can not be disabled.
When soft delete is enabled, it is possible to purge soft deleted vaults and vault items.

## RECOMMENDATION

Consider enabling soft delete on Key Vaults to enable recovery of vaults and vault items.

## EXAMPLES

### Configure with Azure template

To deploy Key Vaults that pass this rule:

- Set the `properties.enableSoftDelete` property to `true`.

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

- Set the `properties.enableSoftDelete` property to `true`.

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

---
reviewed: 2024-02-02
severity: Important
pillar: Reliability
category: RE:07 Self-preservation
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

- Set the `properties.enableSoftDelete` property to `true`.

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

<!-- external:avm avm/res/key-vault/vault enableSoftDelete -->

### Configure with Azure CLI

```bash
az keyvault update -n '<name>' -g '<resource_group>' --retention-days 90
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Key vaults should have soft delete enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Key%20Vault/SoftDeleteMustBeEnabled_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/1e66c121-a66a-4b1f-9b83-0fd99bf0fc2d`.

## LINKS

- [RE:07 Self-preservation](https://learn.microsoft.com/azure/well-architected/reliability/self-preservation)
- [Azure Key Vault soft-delete overview](https://learn.microsoft.com/azure/key-vault/general/soft-delete-overview)
- [Soft-delete will be enabled on all key vaults](https://learn.microsoft.com/azure/key-vault/general/soft-delete-change)
- [Azure Key Vault security](https://learn.microsoft.com/azure/key-vault/general/security-features)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults)

---
severity: Important
pillar: Security
category: Identity and access management
resource: Key Vault
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/en/rules/Azure.KeyVault.AccessPolicy.md
---

# Limit access to Key Vault data

## SYNOPSIS

Use the principal of least privilege when assigning access to Key Vault.

## DESCRIPTION

Key Vault is a service designed to securely store sensitive items such as secrets, keys and certificates.
Access Policies determine the permissions user accounts, groups or applications have to Key Vaults items.

The ability for applications and administrators to get, set and list within a Key Vault is commonly required.
However should only be assigned to security principals that require access.
The purge permission should be rarely assigned.

## RECOMMENDATION

Consider assigning access to Key Vault data based on the principle of least privilege.

## EXAMPLES

### Azure templates

To deploy key vaults access policies that pass this rule:

- Avoid assigning `Purge` and `All` permissions for Key Vault objects.

For example:

```json
{
    "comments": "Create or update a Key Vault.",
    "type": "Microsoft.KeyVault/vaults",
    "name": "[parameters('vaultName')]",
    "apiVersion": "2019-09-01",
    "location": "[parameters('location')]",
    "properties": {
        "accessPolicies": [
            {
                "objectId": "<object_id>",
                "tenantId": "<tenant_id>",
                "permissions": {
                    "secrets": [
                        "Get",
                        "List",
                        "Set"
                    ]
                }
            }
        ],
        "tenantId": "[subscription().tenantId]",
        "sku": {
            "name": "Standard",
            "family": "A"
        }
    }
}
```

## LINKS

- [Best practices to use Key Vault](https://docs.microsoft.com/azure/key-vault/general/best-practices)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.keyvault/vaults)

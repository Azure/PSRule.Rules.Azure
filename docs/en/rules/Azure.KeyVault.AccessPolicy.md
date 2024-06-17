---
reviewed: 2024-06-17
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.AccessPolicy/
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

To deploy Key Vaults that pass this rule:

- Use Azure RBAC as the authorization system instead. _OR_
- Configure the access policies by setting `properties.accessPolicies`:
  - Avoid assigning `purge` and `all` permissions for Key Vault objects.
    Use specific permissions such as `get` and `set`.

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
    "accessPolicies": [
      {
        "objectId": "[parameters('objectId')]",
        "permissions": {
          "secrets": [
            "get",
            "list",
            "set"
          ]
        },
        "tenantId": "[tenant().tenantId]"
      }
    ]
  }
}
```

### Configure with Bicep

To deploy Key Vaults that pass this rule:

- Use Azure RBAC as the authorization system instead. _OR_
- Configure the access policies by setting `properties.accessPolicies`:
  - Avoid assigning `purge` and `all` permissions for Key Vault objects.
    Use specific permissions such as `get` and `set`.

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
    accessPolicies: [
      {
        objectId: objectId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
        tenantId: tenant().tenantId
      }
    ]
  }
}
```

<!-- external:avm avm/res/key-vault/vault accessPolicies -->

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Provide access to Key Vault keys, certificates, and secrets with an Azure role-based access control](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure role-based access control vs. access policies](https://learn.microsoft.com/azure/key-vault/general/rbac-access-policy)
- [Migrate from vault access policy to an Azure role-based access control permission model](https://learn.microsoft.com/azure/key-vault/general/rbac-migration)
- [Best practices to use Key Vault](https://learn.microsoft.com/azure/key-vault/general/best-practices)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults)

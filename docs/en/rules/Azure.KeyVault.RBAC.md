---
severity: Awareness
pillar: Security 
category: Identity and access management
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.RBAC/
---

# Use Azure role-based access control

## SYNOPSIS

Key Vaults should use Azure RBAC as the authorization system for the data plane.

## DESCRIPTION

Azure RBAC is the recommended authorization system for the Azure Key Vault data plane.

Azure RBAC allows users to manage key, secrets, and certificates permissions. It provides one place to manage all permissions across all Key Vaults.

Azure RBAC for Key Vault also allows users to have separate permissions on individual keys, secrets, and certificates.

The Azure RBAC permission model is not enabled by default.

## RECOMMENDATION

Consider using Azure RBAC as the authorization system on Key Vaults for the data plane.

## EXAMPLES

### Configure with Azure template

To deploy Key Vaults that pass this rule:

- Set the `properties.enableRbacAuthorization` property to `true`.

For example:

```json
{
    "type": "Microsoft.KeyVault/vaults",
    "apiVersion": "2022-07-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "properties": {
        "sku": {
            "family": "A",
            "name": "standard"
        },
        "tenantId": "[subscription().tenantId]",
        "enableRbacAuthorization": true
    }
}
```

### Configure with Bicep

To deploy Key Vaults that pass this rule:

- Set the `properties.enableRbacAuthorization` property to `true`.

For example:

```bicep
resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}
```

### Configure with Azure CLI

```bash
az keyvault update -n '<name>' -g '<resource_group>' --enable-rbac-authorization
```

### Configure with Azure PowerShell

```powershell
Update-AzKeyVault -ResourceGroupName '<resource_group>' -Name '<name>' -EnableRbacAuthorization
```

## NOTES

The Azure RBAC permission model has disadvantages when compared to access policies, that might effect e.g infrastructure as code deployments. There are scenarios where Azure RBAC might not be suitable. More about this in the `LINKS` section.

## LINKS

- [Role-based authorization](https://learn.microsoft.com/azure/well-architected/security/design-identity-authorization#role-based-authorization)
- [What is Azure role-based access control?](https://learn.microsoft.com/azure/key-vault/general/soft-delete-overview)
- [Provide access to Key Vault keys, certificates, and secrets with an Azure role-based access control](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure role-based access control vs. access policies](https://learn.microsoft.com/azure/key-vault/general/rbac-access-policy)
- [Migrate from vault access policy to an Azure role-based access control permission model](https://learn.microsoft.com/azure/key-vault/general/rbac-migration)
- [Azure security baseline for Key Vault](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults#vaultproperties)

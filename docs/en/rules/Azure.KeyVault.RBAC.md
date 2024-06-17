---
reviewed: 2024-02-02
severity: Awareness
pillar: Security
category: SE:05 Identity and access management
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.RBAC/
---

# Use Azure role-based access control

## SYNOPSIS

Key Vaults should use Azure RBAC as the authorization system for the data plane.

## DESCRIPTION

Azure RBAC is the recommended authorization system for the Azure Key Vault data plane.

Azure RBAC allows users to manage key, secrets, and certificates permissions.
It provides one place to manage all permissions across all Key Vaults.

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

- Set the `properties.enableRbacAuthorization` property to `true`.

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

<!-- external:avm avm/res/key-vault/vault enableRbacAuthorization -->

### Configure with Azure CLI

```bash
az keyvault update -n '<name>' -g '<resource_group>' --enable-rbac-authorization
```

### Configure with Azure PowerShell

```powershell
Update-AzKeyVault -ResourceGroupName '<resource_group>' -Name '<name>' -EnableRbacAuthorization
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Key Vault should use RBAC permission model](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Key%20Vault/Should_Use_RBAC.json)
  `/providers/Microsoft.Authorization/policyDefinitions/12d4fa5e-1f9f-4c21-97a9-b99b3c6611b5`.

## NOTES

The RBAC permission model may not be suitable for all use cases.
If this rule is not suitable for your use case, you can exclude or suppress the rule.
For information about limitations see _Azure role-based access control vs. access policies_ in the `LINKS` section.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [What is Azure role-based access control?](https://learn.microsoft.com/azure/role-based-access-control/overview)
- [Provide access to Key Vault keys, certificates, and secrets with an Azure role-based access control](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure role-based access control vs. access policies](https://learn.microsoft.com/azure/key-vault/general/rbac-access-policy)
- [Migrate from vault access policy to an Azure role-based access control permission model](https://learn.microsoft.com/azure/key-vault/general/rbac-migration)
- [Azure Key Vault security](https://learn.microsoft.com/azure/key-vault/general/security-features)
- [Azure security baseline for Key Vault](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults)

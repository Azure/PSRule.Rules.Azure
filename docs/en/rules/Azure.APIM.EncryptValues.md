---
severity: Important
pillar: Security
category: Data protection
resource: API Management
resourceType: Microsoft.ApiManagement/service,Microsoft.ApiManagement/service/namedValues
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.EncryptValues/
---

# Use encrypted named values

## SYNOPSIS

Encrypt all API Management named values with Key Vault secrets.

## DESCRIPTION

Named values can be used to manage constant string values and secrets across all API configurations and policies.

Named values are a global collection of name/value pairs in each API Management instance, which may contain sensitive information.

Secret values can be stored either as encrypted strings in API Management (custom secrets) or by referencing secrets in Azure Key Vault.

All secrets in Key Vault are stored encrypted.

Using Key Vault secrets is recommended because it helps improve API Management security by:

- Granular access policies and audit logs can be used with secrets.
- Making it easier to rotate secrets within Key Vault.
- Secrets that are rotated in Key Vault are automatically refreshed within API Management within 4 hours.
  You can also manually refresh the secret using the Azure portal or via the management REST API.

## RECOMMENDATION

Consider encrypting all API Management named values with Key Vault secrets.

### Configure with Azure template

To deploy API Management named values that pass this rule:

- Configure a named value sub-resource.
- Configure the `properties.keyVault.secretIdentifier` property.

For example:

```json
{
  "type": "Microsoft.ApiManagement/service/namedValues",
  "apiVersion": "2022-08-01",
  "name": "[format('{0}/{1}', parameters('name'), parameters('namedValue'))]",
  "properties": {
    "displayName": "[parameters('namedValue')]",
    "keyVault": {
      "identityClientId": null,
      "secretIdentifier": "[format('https://myVault.vault.azure.net/secrets/{0}', parameters('namedValue'))]"
    },
    "tags": []
  },
  "dependsOn": [
    "[resourceId('Microsoft.ApiManagement/service', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy API Management named values that pass this rule:

- Configure a named value sub-resource.
- Configure the `properties.keyVault.secretIdentifier` property.

For example:

```bicep
resource apimNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: namedValue
  parent: apim
  properties: {
    displayName: namedValue
    keyVault: {
      identityClientId: null
      secretIdentifier: 'https://myVault.vault.azure.net/secrets/${namedValue}'
    }
    tags: []
  }
}
```

## NOTES

Using Key Vault secrets requires a system-assigned or user-assigned managed identity assigned to the API Management instance.
The identity needs permissions to get and list secrets from the Key Vault. Also make sure to read the `Prerequisites for key vault integration` section in links.

## LINKS

- [Key storage](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-keys#key-storage)
- [Prerequisites for key vault integration](https://learn.microsoft.com/azure/api-management/api-management-howto-properties?tabs=azure-portal#prerequisites-for-key-vault-integration)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/namedvalues#keyvaultcontractcreatepropertiesorkeyvaultcontractpr)

---
reviewed: 2024-10-26
severity: Critical
pillar: Security
category: SE:02 Secured development lifecycle
resource: Deployment
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.SecureValue/
---

# Deployment sets a secret property with a non-secure value

## SYNOPSIS

A secret property set from a non-secure value may leak the secret into deployment history or logs.

## DESCRIPTION

Azure Bicep and Azure Resource Manager (ARM) templates can be used to deploy resources to Azure.
When deploying Azure resources, sensitive values such as passwords, certificates, and keys should be passed as secure parameters.
Secure parameters use the `@secure` decorator in Bicep or the `secureString` / `secureObject` type.

Parameters that do not use secure types are recorded in deployment history and logs.
These values can be retrieved by anyone with read access to the deployment history and logs.
Logs are often exposed at multiple levels including CI pipeline logs, Azure Activity Logs, and SIEM systems.

<!-- security:note rotate-secret -->

## RECOMMENDATION

Consider using secure parameters for setting the value of any sensitive resource properties.

## EXAMPLES

### Configure with Azure template

To configure deployments that pass this rule:

- Set the `type` of parameters used set sensitive resource properties to `secureString` or `secureObject`.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "secret": {
      "type": "secureString"
    }
  },
  "resources": [
    {
      "type": "Microsoft.KeyVault/vaults/secrets",
      "apiVersion": "2022-07-01",
      "name": "keyvault/good",
      "properties": {
        "value": "[parameters('secret')]"
      }
    }
  ]
}
```

### Configure with Bicep

To configure deployments that pass this rule:

- Add the `@secure()` decorators on parameters used to set sensitive resource properties.

For example:

```bicep
@secure()
param secret string

resource goodSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'keyvault/good'
  properties: {
    value: secret
  }
}
```

## NOTES

For a list of resource types and properties that are checked by this rule see [secret properties][1].
If you find properties that are missing, please let us know by logging an issue on GitHub.

  [1]: https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/secret-property.json

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Secure parameters](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters#secure-parameters)
- [Use Azure Key Vault to pass secure parameter value during Bicep deployment](https://learn.microsoft.com/azure/azure-resource-manager/bicep/key-vault-parameter)
- [Integrate Azure Key Vault in your ARM template deployment](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-tutorial-use-key-vault#edit-the-parameters-file)

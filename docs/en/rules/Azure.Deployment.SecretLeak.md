---
reviewed: 2025-04-11
severity: Critical
pillar: Security
category: SE:02 Secured development lifecycle
resource: Deployment
resourceType: Microsoft.Resources/deployments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.SecretLeak/
---

# Deployment parameter contains a secret that is not secured

## SYNOPSIS

Sensitive parameters that have been not been marked as secure may leak the secret into deployment history or logs.

## DESCRIPTION

This rule detects cases when a sensitive value is passed to a parameter that is not marked as secure.
For example, you used `listKeys` to get a storage account key and then passed the value to a parameter of a child module.
The parameter on the child module is not marked as secure, so the value has been leaked by the child deployment.

Azure Bicep and Azure Resource Manager (ARM) templates can be used to deploy resources to Azure.
When deploying Azure resources, sensitive values such as passwords, certificates, and keys should be passed as secure parameters.
Secure parameters use the `@secure` decorator in Bicep or the `secureString` / `secureObject` type.

Parameters that do not use secure types are recorded in deployment history and logs.
These values can be retrieved by anyone with read access to the deployment history and logs.

<!-- security:note rotate-secret -->

<!-- security:note non-secret-values -->

## RECOMMENDATION

Consider using secure parameters for any parameter that contain sensitive information.

## EXAMPLES

### Configure with Azure template

To configure deployments that pass this rule:

- Set the type of sensitive parameters to `secureString` or `secureObject`.

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

- Add the `@secure()` decorators on sensitive parameters.

For example:

```bicep
@secure()
param secret string

resource goodSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: vault
  name: 'good'
  properties: {
    value: secret
  }
}
```

## NOTES

Sensitive values detected include:

- Key Vault secret references.
- The output of a `list*` function such as `listKeys`.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Secure parameters](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters#secure-parameters)
- [Use Azure Key Vault to pass secure parameter value during Bicep deployment](https://learn.microsoft.com/azure/azure-resource-manager/bicep/key-vault-parameter)
- [Integrate Azure Key Vault in your ARM template deployment](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-tutorial-use-key-vault#edit-the-parameters-file)

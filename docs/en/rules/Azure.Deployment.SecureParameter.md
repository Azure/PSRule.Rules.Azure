---
reviewed: 2025-04-11
severity: Critical
pillar: Security
category: SE:02 Secured development lifecycle
resource: Deployment
resourceType: Microsoft.Resources/deployments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.SecureParameter/
---

# Deployment parameter name implies it is secret but is a non-secure value

## SYNOPSIS

Sensitive parameters that have been not been marked as secure may leak the secret into deployment history or logs.

## DESCRIPTION

This rule uses a heuristics to determine if a parameter should use a secure type based on how it is named.
For example if the parameter is named `password` it is likely to contain a password value.
However, there are cases when the parameter name may be confused with a sensitive value, but the value is not sensitive.
See notes below for more details.

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

The following business logic is used to determine if a parameter is marked as secure or not:

- Parameters with the type `int` or `bool` are ignored regardless of how they are named.
- Parameters named ending with `name`, `uri`, `url`, `path`, `type`, `id`, or `options` are ignored.
- Any remaining parameters with a name containing `password`, `secret`, or `token` will be considered sensitive.
  Except if they contains any of the following in sequences in their name:
    `length`, `interval`, `secretname`, `secreturl`, `secreturi`, `secrettype`, `secretrotation`,
    `secretprovider`, `secretsprovider`, `secretref`, `secretid`, `disablepassword`, `sync*passwords`,
    `tokenname`, `tokentype`, `keyvaultpath`, `keyvaultname`, or `keyvaulturi`.
- Any remaining parameters with a name ending in `key` or `keys` will be considered sensitive.
  Except for:
  - The `customermanagedkey` parameter.
  - Parameter names ending in `publickey` or `publickeys`.

### Rule configuration

<!-- module:config rule AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES -->

If you identify a parameter that is _not sensitive_, and is incorrectly flagged by this rule, you can override the rule.
To override this rule:

- Set the `AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES` configuration value to identify parameters that are not sensitive.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Secure parameters](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters#secure-parameters)
- [Use Azure Key Vault to pass secure parameter value during Bicep deployment](https://learn.microsoft.com/azure/azure-resource-manager/bicep/key-vault-parameter)
- [Integrate Azure Key Vault in your ARM template deployment](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-tutorial-use-key-vault#edit-the-parameters-file)

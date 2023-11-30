---
reviewed: 2023-11-13
severity: Critical
pillar: Security
category: Infrastructure provisioning
resource: Deployment
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.SecureParameter/
---

# Use secure parameters for sensitive information

## SYNOPSIS

Use secure parameters for any parameter that contains sensitive information.

## DESCRIPTION

Azure Bicep and Azure Resource Manager (ARM) templates can be used to deploy resources to Azure.
When deploying Azure resources, sensitive values such as passwords, certificates, and keys should be passed as secure parameters.
Secure parameters use the `secureString` or `secureObject` type.

Parameters that do not use secure types are recorded in logs and deployment history.
These values can be retrieved by anyone with access to the deployment history.

## RECOMMENDATION

Consider using secure parameters for parameters that contain sensitive information.

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

- Add the `@secure()` attribute on sensitive parameters.

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

This rule uses a heuristics to determine if a parameter should use a secure type:

- Parameters with the type `int` or `bool` are ignored regardless of how they are named.
- Any parameter with a name containing `password`, `secret`, or `token` will be considered sensitive.
  - Except parameter names containing any of the following:
    `passwordlength`, `secretname`, `secreturl`, `secreturi`, `secretrotation`, `secretinterval`, `secretprovider`,
    `secretsprovider`, `secretref`, `secretid`, `disablepassword`, `sync*passwords`, or `tokenname`.
- Any parameter with a name ending in `key` or `keys` will be considered sensitive.
  - Except parameter names ending in `publickey` or `publickeys`.

If you identify a parameter that is _not sensitive_, and is incorrectly flagged by this rule, you can override the rule.
To override this rule:

- Set the `AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES` configuration value to identify parameters that are not sensitive.

## LINKS

- [Infrastructure provisioning considerations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/deploy-infrastructure)
- [Use Azure Key Vault to pass secure parameter value during Bicep deployment](https://learn.microsoft.com/azure/azure-resource-manager/bicep/key-vault-parameter)
- [Integrate Azure Key Vault in your ARM template deployment](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-tutorial-use-key-vault#edit-the-parameters-file)

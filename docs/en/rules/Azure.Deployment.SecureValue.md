---
reviewed: 2022-10-10
severity: Critical
pillar: Security
category: Infrastructure provisioning
resource: Deployment
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.SecureValue/
---

# Use secure resource values

## SYNOPSIS

Use secure parameters for setting properties of resources that contain sensitive information.

## DESCRIPTION

Azure Bicep and Azure Resource Manager (ARM) templates can be used to deploy resources to Azure.
When deploying Azure resources, sensitive values such as passwords, certificates, and keys should be passed as secure parameters.
Secure parameters use the `secureString` or `secureObject` type.

Parameters that do not use secure types are recorded in logs and deployment history.
These values can be retrieved by anyone with access to the deployment history.

## RECOMMENDATION

Consider using secure parameters for sensitive resource properties.

## EXAMPLES

### Configure with Azure template

To configure deployments that pass this rule:

- Set the type of parameters used set sensitive resource properties to `secureString` or `secureObject`.

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

- Add the `@secure()` attribute on parameters used to set sensitive resource properties.

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

This rule checks the following resource type properties:

- `Microsoft.KeyVault/vaults/secrets`:
  - `properties.value`
- `Microsoft.Compute/virtualMachineScaleSets`:
  - `properties.virtualMachineProfile.osProfile.adminPassword`

## LINKS

- [Infrastructure provisioning considerations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/deploy-infrastructure)
- [Use Azure Key Vault to pass secure parameter value during Bicep deployment](https://learn.microsoft.com/azure/azure-resource-manager/bicep/key-vault-parameter)
- [Integrate Azure Key Vault in your ARM template deployment](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-tutorial-use-key-vault#edit-the-parameters-file)

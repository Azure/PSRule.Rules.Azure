---
reviewed: 2022-06-12
severity: Critical
pillar: Security
category: Infrastructure provisioning
resource: Deployment
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.OutputSecretValue/
---

# Secret value in deployment output

## SYNOPSIS

Avoid outputting sensitive deployment values.

## DESCRIPTION

Don't include any values in an ARM template or Bicep output that could potentially expose secrets.
The output from a template is stored in the deployment history, so a malicious user could find that information.

Examples of secrets are:

- Parameters using the `secureString` or `secureObject` type.
- Output from `list*` functions such as `listKeys`.

## RECOMMENDATION

Consider removing any output values that return secret values in code.

## EXAMPLES

### Configure with Azure template

To deploy securely pass secrets within Infrastructure as Code:

- Define parameters with the `secureString` or `secureObject` type.
- Avoid returning a secret in output values.

Example using `secureString` type:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminPassword": {
      "type": "secureString",
      "metadata": {
        "description": "Local administrator password for virtual machine."
      }
    }
  },
  "resources": []
}
```

The following example fails because it returns a secret:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "adminPassword": {
      "type": "secureString",
      "metadata": {
        "description": "Local administrator password for virtual machine."
      }
    }
  },
  "resources": [],
  "outputs": {
    "accountPassword": {
      "type": "string",
      "value": "[parameters('adminPassword')]"
    }
  }
}
```

### Configure with Bicep

To deploy securely pass secrets within Infrastructure as Code:

- Mark secrets with the `@secure()` annotation.
- Avoid returning a secret in output values.

Example using `@secure()` annotation:

```bicep
@secure()
@description('Local administrator password for virtual machine.')
param adminPassword string
```

The following example fails because it returns a secret:

```bicep
output accountPassword string = adminPassword
```

## LINKS

- [Pipeline secret management](https://learn.microsoft.com/azure/architecture/framework/security/deploy-infrastructure#pipeline-secret-management)
- [Test cases for ARM templates](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-test-cases#outputs-cant-include-secrets)
- [Outputs should not contain secrets](https://learn.microsoft.com/azure/azure-resource-manager/bicep/linter-rule-outputs-should-not-contain-secrets)
- [List function](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions-resource#list)

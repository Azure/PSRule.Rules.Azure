---
reviewed: 2025-04-11
severity: Critical
pillar: Security
category: SE:02 Secured development lifecycle
resource: Deployment
resourceType: Microsoft.Resources/deployments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.OutputSecretValue/
---

# Deployment exposes a secret in output

## SYNOPSIS

Outputting a sensitive value from deployment may leak secrets into deployment history or logs.

## DESCRIPTION

This rule checks for cases when a sensitive value is output from a deployment.
For example, if a parameter is marked as secure and then assigned to an output value.

Don't include any values in an ARM template or Bicep output that could potentially expose sensitive information.
The output from each deployment is stored in the deployment history.
If the output contains sensitive information, the output value is leaked to the deployment history.

Examples of secrets are:

- Parameters using the `secureString` or `secureObject` type.
- Output from `list*` functions such as `listKeys`.

Outputs are recorded in clear texts within deployment history and logs.
Logs are often exposed at multiple levels including CI pipeline logs, Azure Activity Logs, and SIEM systems.

<!-- security:note rotate-secret -->

## RECOMMENDATION

Consider removing any output values that return secret values in code.

## EXAMPLES

### Configure with Bicep

To deploy securely pass secrets within Infrastructure as Code:

- Add the `@secure()` decorators on sensitive parameters.
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

## NOTES

When using Bicep, the built-in linter will also automatically check for common cases when secrets are output from a deployment.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Test cases for ARM templates](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-test-cases#outputs-cant-include-secrets)
- [Outputs should not contain secrets](https://learn.microsoft.com/azure/azure-resource-manager/bicep/linter-rule-outputs-should-not-contain-secrets)
- [List function](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions-resource#list)

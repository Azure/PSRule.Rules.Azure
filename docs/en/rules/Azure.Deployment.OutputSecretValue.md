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

This rule checks for cases when a sensitive value is insecurely output from a deployment or module.
For example, if a parameter is marked as secure and then assigned to an output value;
or a `list*` function is used to retrieve an account key and then assigned to an output value.

When deploying Azure resources across multiple deployments it is often helpful to pass values between them as outputs.
By default, outputs are recorded as clear text within deployment history and logs.
These values can be retrieved by anyone with read access to the deployment history and logs.
Logs are often exposed at multiple levels including CI pipeline logs, Azure Activity Logs, and SIEM systems.

For passing sensitive values such as keys or tokens use secure outputs.
Secure outputs use the `@secure` decorator in Bicep or the `secureString` / `secureObject` type.
Outputs that are marked as secure are not recorded in ARM deployment history or logs.

Additionally, it is often unnecessary to output sensitive values from a deployment since Azure provides,
multiple ways to retrieve sensitive values from resources at runtime such `list*` functions.
Avoid unnecessarily outputting and handling sensitive values from a deployment.

<!-- security:note rotate-secret -->

## RECOMMENDATION

Consider removing any deployment output values that return secret values or use secure outputs.

## EXAMPLES

### Configure with Bicep

To configure deployments that pass this rule:

- Add the `@secure()` decorators on parameters or outputs that contain sensitive information.

Example using `@secure()` annotation on a parameter:

```bicep
@secure()
@description('Local administrator password for virtual machine.')
param adminPassword string
```

Example using `@secure()` annotation on an output:

```bicep
@secure()
output accountKey string = storage.listKeys().keys[0].value
```

### Configure with Azure template

To configure deployments that pass this rule:

- Use the `secureString` or `secureObject` type on parameters or outputs that contain sensitive information.

Example using `secureString` type on a parameter:

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

Example using `secureString` type on an output:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [],
  "outputs": {
    "accountKey": {
      "type": "secureString",
      "value": "[listKeys('storage', '2021-09-01').keys[0].value]"
    }
  }
}
```

## NOTES

When using Bicep, the built-in linter will also automatically check for common cases when secrets are output from a deployment.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Secure outputs in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/outputs#secure-outputs)
- [Test cases for ARM templates](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-test-cases#outputs-cant-include-secrets)
- [Outputs should not contain secrets](https://learn.microsoft.com/azure/azure-resource-manager/bicep/linter-rule-outputs-should-not-contain-secrets)
- [List function](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions-resource#list)

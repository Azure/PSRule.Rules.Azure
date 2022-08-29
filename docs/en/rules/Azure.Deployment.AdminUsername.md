---
severity: Awareness
pillar: Security
category: Design
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.AdminUsername/
---

# Administrator Username Types

## SYNOPSIS

The adminUsername or administratorUsername property should not be a string literal in nested templates.

## DESCRIPTION

In nested deployments a resource can have the adminUsername property set to a string literal value.
This means that the value is passed through insecurely and is a security risk.

## RECOMMENDATION

Sensitive properties for nested deployments should be set by a secureString parameter.

- [Use KeyVault Secrets in Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/key-vault-parameter)
- [Use KeyVault Secret in Parameter File](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-tutorial-use-key-vault#edit-the-parameters-file)

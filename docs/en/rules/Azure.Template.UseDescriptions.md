---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.UseDescriptions/
---

# Use comments for each generated template resource

## SYNOPSIS

Use descriptions for each resource in generated template(bicep, psarm, AzOps) to communicate purpose.

## DESCRIPTION

Generated templates can optionally include descriptions in resources.
This helps other contributors understand the purpose of the resource.

## RECOMMENDATION

Specify descriptions for each resource in the template.

## EXAMPLES

### Configure with Bicep

To define Bicep template files that pass this rule:

- Specify the `@description()` or `@sys.description()` decorator for each resource in the template.

For example:

```bicep
// An example container registry
@description('abc')
resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 30
      }
    }
  }
}
```

## LINKS

- [Better understand your cloud resources](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure#better-understand-your-cloud-resources)
- [Decorators](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters#decorators)

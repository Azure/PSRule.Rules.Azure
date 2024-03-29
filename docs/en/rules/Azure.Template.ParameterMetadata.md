---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ParameterMetadata/
---

# Use template parameter descriptions

## SYNOPSIS

Set metadata descriptions in Azure Resource Manager (ARM) template for each parameter.

## DESCRIPTION

ARM templates supports an additional metadata description to be added to each parameter.
The parameter description is visible in Azure when using portal deployment pages.
Additionally, descriptions provide context for people editing template and parameter files.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountType": {
      "type": "string",
      "metadata": {
          "description": "The type of the new storage account created to store the VM disks."
      }
    }
  }
}
```

## RECOMMENDATION

Consider defining a metadata description for each template parameter.

## LINKS

- [Parameters](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)
- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#general-recommendations-for-parameters)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)

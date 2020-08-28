---
severity: Awareness
pillar: Operational Excellence
category: Deployment
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.ParameterMetadata.md
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

- [ARM template best practices](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-best-practices#general-recommendations-for-parameters)

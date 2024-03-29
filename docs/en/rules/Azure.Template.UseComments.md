---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.UseComments/
---

# Use comments for each ARM template resource

## SYNOPSIS

Use comments for each resource in ARM template to communicate purpose.

## DESCRIPTION

ARM templates can optionally include comments in resources.
This helps other contributors understand the purpose of the resource.

## RECOMMENDATION

Specify comments for each resource in the template.

## EXAMPLES

### Configure with Azure template

To define Azure template files that pass this rule:

- Specify `comments` for each resource in the template.

For example:

```json
"resources": [
  {
    "name": "[variables('storageAccountName')]",
    "type": "Microsoft.Storage/storageAccounts",
    "apiVersion": "2019-06-01",
    "location": "[resourceGroup().location]",
    "comments": "This storage account is used to store the VM disks.",
      ...
  }
]
```

## LINKS

- [Better understand your cloud resources](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure#better-understand-your-cloud-resources)
- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/best-practices#resources)

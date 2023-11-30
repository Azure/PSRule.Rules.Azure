---
reviewed: 2023-04-20
severity: Awareness
pillar: Cost Optimization
category: CO:03 Cost data and reporting
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Resource.UseTags/
ms-content-id: d8480c0d-e41c-441a-9b03-0dc9c340c149
---

# Use resource tags

## SYNOPSIS

Azure resources should be tagged using a standard convention.

## DESCRIPTION

Azure Resource Manager (ARM) supports a flexible tagging model that allows each resource to be tagged.
Tags are additional metadata that improves identification of resources and aids lifecycle management.

Azure stores tags as name/ value pairs such as `environment = production` or `costCode = 349921`.

A well defined tagging approach improves the management, billing, and automation operations of resources.
When planning tags, identify information that is meaningful to business and technical staff.

Azure provides several built-in policies to managed tags.
Using these policies help enforce a tagging standard can reduce overall management
Resource tags can be inherited from subscriptions or resource groups using Azure Policy.

## RECOMMENDATION

Consider tagging resources using a standard convention.
Identify mandatory and optional tags then tag all resources and resource groups using this standard.

Also consider using Azure Policy to enforce mandatory tags.

## EXAMPLES

### Configure with Azure template

To deploy resource that pass this rule:

- Set the `tags` property tags that align to your tagging standard.

For example:

```json
{
  "type": "Microsoft.Resources/resourceGroups",
  "apiVersion": "2022-09-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "tags": {
    "environment": "production",
    "costCode": "349921"
  }
}
```

### Configure with Bicep

To deploy resource that pass this rule:

- Set the `tags` property tags that align to your tagging standard.

For example:

```bicep
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: name
  location: location
  tags: {
    environment: 'production'
    costCode: '349921'
  }
}
```

## NOTES

Azure Policy includes several built-in policies to enforce tagging such as:

- _Add a tag to resources_
- _Add a tag to resource groups_
- _Require a tag on resources_
- _Require a tag on resource groups_
- _Inherit a tag from the resource group_
- _Inherit a tag from the resource group if missing_
- _Inherit a tag from the subscription_

If you find resources that incorrectly report they should be tagged, please let us know by [opening an issue][1].

  [1]: https://github.com/Azure/PSRule.Rules.Azure/issues/new/choose

## LINKS

- [CO:03 Cost data and reporting](https://learn.microsoft.com/azure/well-architected/cost-optimization/collect-review-cost-data)
- [Tag support for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/tag-support)
- [Develop your naming and tagging strategy for Azure resources](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Define your tagging strategy](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
- [Resource naming and tagging decision guide](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming-and-tagging-decision-guide)
- [Assign policy definitions for tag compliance](https://learn.microsoft.com/azure/azure-resource-manager/management/tag-policies)
- [Enforcing custom tags](https://azure.github.io/PSRule.Rules.Azure/customization/enforce-custom-tags/)

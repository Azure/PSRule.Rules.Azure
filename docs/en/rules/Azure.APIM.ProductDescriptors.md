---
reviewed: 2023-21-05
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.ProductDescriptors/
---

# Use product descriptors

## SYNOPSIS

API Management products should have a display name and description.

## DESCRIPTION

Each product created in API Management can have a display name and description set.
Using easy to understand descriptions and metadata greatly assists identification for management and usage.

During monitoring from service provider perspective:

- Having a clear understanding of the purpose of a product is often important to during analysis.
- Allows for accurate management and clean up of unused or old products.
- Allows for accurate access control decisions.

This information is visible within the developer portal.
Accurate information can be used to assist developers in understanding the purpose of a product.

## RECOMMENDATION

Consider using display name and description fields on products to convey intended purpose and usage.
Display name and description fields should be human readable and easy to understand.

## EXAMPLES

### Configure with Azure template

To deploy API Management Products that pass this rule:

- Set the `properties.displayName` with a human readable name.
- Set the `properties.description` with an description of the APIs purpose.

For example:

```json
{
  "type": "Microsoft.ApiManagement/service/products",
  "apiVersion": "2022-08-01",
  "name": "[format('{0}/{1}', parameters('name'), 'echo')]",
  "properties": {
    "displayName": "Echo",
    "description": "Echo API services for Contoso.",
    "approvalRequired": true,
    "subscriptionRequired": true
  },
  "dependsOn": [
    "[resourceId('Microsoft.ApiManagement/service', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy API Management Products that pass this rule:

- Set the `properties.displayName` with a human readable name.
- Set the `properties.description` with an description of the APIs purpose.

For example:

```bicep
resource product 'Microsoft.ApiManagement/service/products@2022-08-01' = {
  parent: service
  name: 'echo'
  properties: {
    displayName: 'Echo'
    description: 'Echo API services for Contoso.'
    approvalRequired: true
    subscriptionRequired: true
  }
}
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Design review checklist for Operational Excellence](https://learn.microsoft.com/azure/well-architected/operational-excellence/checklist)
- [Create and publish a product](https://learn.microsoft.com/azure/api-management/api-management-howto-add-products)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/products)

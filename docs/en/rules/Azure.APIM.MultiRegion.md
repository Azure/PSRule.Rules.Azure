---
severity: Important
pillar: Reliability
category: Best practices
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.MultiRegion/
---

# Multi-region deployment

## SYNOPSIS

API Management instances should use multi-region deployment to reduce request latency perceived by geographically distributed API consumers.

## DESCRIPTION

Azure API Management supports multi-region deployment, which enables API publishers to add regional API gateways to an existing API Management instance in one or more supported Azure regions. Multi-region deployment helps reduce request latency perceived by geographically distributed API consumers. It also improves the service availability if one region goes offline.

This feature is currently only available for the Premium tier of API Management.

## RECOMMENDATION

Consider to use multi-region deployment to reduce request latency perceived by geographically distributed API consumers and improves service availability if one region goes offline.

## EXAMPLES

### Configure with Azure template

To deploy API Management instances that pass this rule:

- Configure the `properties.additionalLocations` property.

For example:

```json
{
  "type": "Microsoft.ApiManagement/service",
  "apiVersion": "2021-12-01-preview",
  "name": "[parameters('apiManagementServiceName')]",
  "location": "eastus",
  "sku": {
    "name": "Premium",
    "capacity": 1
  },
  "properties": {
    "additionalLocations": [
      {
        "location": "westeurope",
        "sku": {
          "name": "Premium",
          "capacity": 1
        },
        "disableGateway": false
        }
    ]
  }
}
```

### Configure with Bicep

To deploy API Management instances that pass this rule:

- Configure the `properties.additionalLocations` property.

For example:

```bicep
resource apiManagementService 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apiManagementServiceName
  location: 'eastus'
  sku: {
    name: 'Premium'
    capacity: 1
  }
  properties: {
    additionalLocations: [
      {
        location: 'westeurope'
        sku: {
          name: 'Premium'
          capacity: 1
        }
        disableGateway: false
      }
    ]
  }
}
```

## NOTES

This rule is only applicable for API Management instances configured with a Premium tier.

It is recommended to configure zone redundancy if the region supports it.

Virtual network settings must be configured in the added region, if networking is configured in the existing region or regions. The rule does not take this into consideration.

When using the `resourceGroup()` function PSRule for Azure will provide a default meaning that can be configured. Check out the `LINKS` section for more information.

## LINKS

- [Best practices](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-best-practices)
- [Azure API Management instance multi-region](https://learn.microsoft.com/azure/api-management/api-management-howto-deploy-multi-region)
- [PSRule for Azure resourceGroup() function](https://azure.github.io/PSRule.Rules.Azure/expanding-source-files/#resource-group)
- [Azure template reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)

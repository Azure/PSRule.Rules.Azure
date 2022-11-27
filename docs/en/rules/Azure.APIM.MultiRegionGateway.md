---
severity: Important
pillar: Reliability
category: Resiliency and dependencies
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.MultiRegionGateway/
---

# Multi-region deployment gateways

## SYNOPSIS

API Management instances should have multi-region deployment gateways enabled.

## DESCRIPTION

Azure API Management supports multi-region deployment. If the *primary* region goes offline, the secondary regions continue to serve API requests using the most recent gateway configuration. If a *region* goes offline, API requests are automatically routed around the failed region to the next closest gateway.

## RECOMMENDATION

Enable multi-region deployment gateways.

## EXAMPLES

### Configure with Azure template

To deploy API Management instances that pass this rule:

- Set the `properties.additionalLocations.disableGateway` property to `false` for each additional location.

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

- Set the `properties.additionalLocations.disableGateway` property to `false` for each additional location.

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

## LINKS

- [Resiliency and dependencies](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
- [About multi-region deployment](https://learn.microsoft.com/azure/api-management/api-management-howto-deploy-multi-region#about-multi-region-deployment)
- [Azure template reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)

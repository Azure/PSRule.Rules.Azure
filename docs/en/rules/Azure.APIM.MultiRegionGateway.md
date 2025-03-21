---
severity: Important
pillar: Reliability
category: Resiliency and dependencies
resource: API Management
resourceType: Microsoft.ApiManagement/service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.MultiRegionGateway/
---

# Multi-region deployment gateways

## SYNOPSIS

API Management instances should have multi-region deployment gateways enabled.

## DESCRIPTION

Azure API Management supports multi-region deployment.
Deploy API Management in multiple locations to:

- Provide active-active redundancy for API gateway requests across Azure regions.
- Serve the request from the closest API gateway region to the original request.

API gateways can be disabled to enabled you to test failover of your API workloads to another region.
When disabled, an API gateway will not route API traffic.
You should reenable API gateways after you have concluded failover testing to ensure that the API gateway is available for failover if another region becomes unavailable.

If a region goes offline, API requests are automatically routed around the failed region to the next closest gateway.

## RECOMMENDATION

Consider enabling each regional API gateway location for multi-region redundancy.

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

<!-- external:avm avm/res/api-management/service additionalLocations -->

## LINKS

- [Resiliency and dependencies](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
- [About multi-region deployment](https://learn.microsoft.com/azure/api-management/api-management-howto-deploy-multi-region#about-multi-region-deployment)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)

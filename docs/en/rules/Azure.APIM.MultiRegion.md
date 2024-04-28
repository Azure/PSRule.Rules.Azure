---
severity: Important
pillar: Reliability
category: Resiliency and dependencies
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.MultiRegion/
---

# Multi-region deployment

## SYNOPSIS

API Management instances should use multi-region deployment to improve service availability.

## DESCRIPTION

Azure API Management supports multi-region deployment.
Multi-region deployment provides availability of the API gateway in more than one region and provides service availability if one region goes offline.

This feature is currently only available for the Premium tier of API Management.

## RECOMMENDATION

Consider deploying an API Management service across multiple regions to improve service availability.

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

## LINKS

- [Resiliency and dependencies](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
- [Azure API Management instance multi-region](https://learn.microsoft.com/azure/api-management/api-management-howto-deploy-multi-region)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)

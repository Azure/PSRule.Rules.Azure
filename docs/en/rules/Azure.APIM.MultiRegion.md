---
reviewed: 2024-06-01
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.MultiRegion/
---

# API Management instances should use multi-region deployment

## SYNOPSIS

Enhance service availability and resilience by deploying API Management instances across multiple regions.

## DESCRIPTION

API Management supports multi-region deployment, which allows the API gateway to be available in more than one region. This configuration enhances service availability by ensuring that if one region experiences an outage, the API gateway remains operational in another region. Multi-region deployment is crucial for maintaining high availability and reducing latency for global users.

This feature is available exclusively in the Premium SKU for API Management.

## RECOMMENDATION

Consider deploying API Management instances across multiple regions to enhance service availability and resilience.

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

It is recommended to configure zone redundancy if the region supports it.

Virtual network settings must be configured in the added region, if networking is configured in the existing region or regions. The rule does not take this into consideration.

For developer environments, suppressing the rule might make sense as configuring multi-region for an API Management instance requries the `Premium` SKU currently.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Resiliency and dependencies](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
- [Azure API Management instance multi-region](https://learn.microsoft.com/azure/api-management/api-management-howto-deploy-multi-region)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)

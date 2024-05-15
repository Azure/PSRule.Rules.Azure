---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.AvailabilityZone.Units/
---

# API management services should use the same number of units as the number of availability zones or greater in a region.

## SYNOPSIS

Configure the same number of units as the number of availability zones or greater in a region.

## DESCRIPTION

Enabling zone redundancy for an API Management instance in a supported region provides redundancy for all service components: gateway, management plane, and developer portal. Azure automatically replicates all service components across the zones that you select. Zone redundancy is only available in the Premium service tier.

When you enable zone redundancy in a region, both in primary and additional regions, consider the number of API Management scale units that need to be distributed. Minimally, configure the same number of units as the number of availability zones, or a multiple so that the units are distributed evenly across the zones. For example, if you select 3 availability zones in a region, you could have 3 units so that each zone hosts one unit.

## RECOMMENDATION

Consider configuring the same number of units as the number of availability zones or greater in a region.

## EXAMPLES

### Configure with Azure template

To deploy API management instances that pass this rule:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`, ensuring the number of zones match `sku.capacity` and/or `properties.additionalLocations[*].zones` to a minimum of two zones from `["1", "2", "3"]`, ensuring the number of zones match `properties.additionalLocations[*].sku.capacity`. 
- Set `sku.name` and/or `properties.additionalLocations[*].sku.name` to `Premium`.

For example:

```json
{
    "type": "Microsoft.ApiManagement/service",
    "apiVersion": "2023-05-01-preview",
    "name": "[parameters('service_api_mgmt_name')]",
    "location": "Australia East",
    "sku": {
        "name": "Premium",
        "capacity": 3
    },
    "zones": [
        "1",
        "2",
        "3"
    ],
    "properties": {
        "publisherEmail": "john.doe@contoso.com",
        "publisherName": "contoso",
        "notificationSenderEmail": "apimgmt-noreply@mail.windowsazure.com",
        "hostnameConfigurations": [
            {
                "type": "Proxy",
                "hostName": "[concat(parameters('service_api_mgmt_name'), '.azure-api.net')]",
                "negotiateClientCertificate": false,
                "defaultSslBinding": true,
                "certificateSource": "BuiltIn"
            }
        ],
        "additionalLocations": [
            {
                "location": "East US",
                "sku": {
                    "name": "Premium",
                    "capacity": 3
                },
                "zones": [
                    "1",
                    "2",
                    "3"
                ],
                "disableGateway": false
            }
        ],
        "virtualNetworkType": "None",
        "disableGateway": false,
        "apiVersionConstraint": {}
    }
}
```

### Configure with Bicep

To set availability zones for a API management service

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`, ensuring the number of zones match `sku.capacity` and/or `properties.additionalLocations[*].zones` to a minimum of two zones from `["1", "2", "3"]`, ensuring the number of zones match `properties.additionalLocations[*].sku.capacity`. 
- Set `sku.name` and/or `properties.additionalLocations[*].sku.name` to `Premium`.

For example:

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: service_api_mgmt_name
  location: 'Australia East'
  sku: {
    name: 'Premium'
    capacity: 3
  }
  zones: [
    '1',
    '2',
    '3'
  ]
  properties: {
    publisherEmail: 'john.doe@contoso.com'
    publisherName: 'contoso'
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: '${service_api_mgmt_test2_name}.azure-api.net'
        negotiateClientCertificate: false
        defaultSslBinding: true
        certificateSource: 'BuiltIn'
      }
    ]
    additionalLocations: [
      {
        location: 'East US'
        sku: {
          name: 'Premium'
          capacity: 3
        }
        zones: [
          '1'
          '2'
          '3'
        ]
        disableGateway: false
      }
    ]
    virtualNetworkType: 'None'
    disableGateway: false
    apiVersionConstraint: {}
  }
}
```

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Units distribution evenly across the zones](https://learn.microsoft.com/azure/api-management/high-availability#availability-zones)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)

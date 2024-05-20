---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.AvailabilityZone/
---

# API management instances should use availability zones in supported regions

## SYNOPSIS

 API Management instances should use availability zones in supported regions for high availability.

## DESCRIPTION

API Management supports using availability zones to provide zone redundency for key components.
Zone redundancy improves resiliency and high availability of the service by deploying scale units across data centers in physically separated zones.

The following are required to deploy a zone redundant configuration:

- API Management is deployed with the Premium SKU.
- At least two scale units must be deployed in separate availbility zones.

Zone redundancy has a different configuration for the primary and additional regions:

- In the primary region, all service components are replicated across zones (gateway, management plane, and developer portal).
- In additional regions, *only* the gateway is replicated across zones.
  As the management plane/developer portal service components are only deployed to the primary region.

## RECOMMENDATION

Consider using at least two (2) scale units and availability zones to improve resiliency of API Management instances to zone failures.

## EXAMPLES

### Configure with Azure template

To set availability zones for a API Management instance:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`, ensuring the number of zones match `sku.capacity`.
- Set `properties.additionalLocations[*].zones` to a minimum of two zones from `["1", "2", "3"]`, ensuring the number of zones match `properties.additionalLocations[*].sku.capacity`. 
- Set `sku.name` and/or `properties.additionalLocations[*].sku.name` to `Premium`.

For example:

```json
{
    "type": "Microsoft.ApiManagement/service",
    "apiVersion": "2021-01-01-preview",
    "name": "[parameters('service_api_mgmt_test2_name')]",
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
                "hostName": "[concat(parameters('service_api_mgmt_test2_name'), '.azure-api.net')]",
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
        "customProperties": {
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168": "false",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11": "false",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10": "false",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30": "false",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11": "false",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10": "false",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30": "false",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2": "false"
        },
        "virtualNetworkType": "None",
        "disableGateway": false,
        "apiVersionConstraint": {}
    }
}
```

### Configure with Bicep

To set availability zones for a API Management instance:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`, ensuring the number of zones match `sku.capacity`.
- Set `properties.additionalLocations[*].zones` to a minimum of two zones from `["1", "2", "3"]`, ensuring the number of zones match `properties.additionalLocations[*].sku.capacity`. 
- Set `sku.name` and/or `properties.additionalLocations[*].sku.name` to `Premium`.

For example:

```bicep
resource service_api_mgmt_test2_name_resource 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: service_api_mgmt_test2_name
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
          capacity: 1
        }
        zones: [
          '1'
        ]
        disableGateway: false
      }
    ]
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    }
    virtualNetworkType: 'None'
    disableGateway: false
    apiVersionConstraint: {}
  }
}
```

## NOTES

This rule applies when analyzing resources deployed to Azure using *pre-flight* and *in-flight* data.

This rule fails when `"zones"` is `null`, `[]` or less than two zones when API Management instance is deployed with Premium SKU and there are supported availability zones for the given region.

Configure `AZURE_APIM_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST` to set additional availability zones that need to be supported which are not in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers/) for namespace `Microsoft.ApiManagement` and resource type `services`.

```yaml
# YAML: The default AZURE_APIM_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_APIM_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

For developer environments, suppressing the rule might make sense as enabling zone redundancy for an API Management instance requries the `Premium` SKU currently.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Availability zone support for Azure API Management](https://learn.microsoft.com/azure/api-management/zone-redundancy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)

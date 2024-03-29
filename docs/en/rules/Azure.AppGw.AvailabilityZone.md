---
severity: Important
pillar: Reliability
category: Design
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.AvailabilityZone/
---

# Application gateways should use Availability zones in supported regions

## SYNOPSIS

Application gateways should use availability zones in supported regions for high availability.

## DESCRIPTION

Application gateways using availability zones improve reliability and ensure availability during failure scenarios
affecting a data center within a region. A zone redundant Application gateway or Web Application Firewall (WAF)
deployment can spread across multiple availability zones, which ensures the application gateway will continue
running even if another zone has gone down. Backend pools for applications can be similarly distributed across
availability zones.

## RECOMMENDATION

Consider using availability zones for Application gateways deployed with V2 SKU (Standard_v2, WAF_v2).

## NOTES

This rule applies when analyzing resources deployed to Azure using *pre-flight* and *in-flight* data.

This rule fails when `"zones"` is `null`, `[]` or not set when the Application gateway is deployed with V2
SKU (Standard_v2, WAF_v2) and there are supported availability zones for the given region.

Configure `AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST` to set additional availability zones that need to be
supported which are not in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers/)
for namespace `Microsoft.Network` and resource type `applicationGateways`.

```yaml
# YAML: The default AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

## EXAMPLES

### Configure with Azure template

To set availability zones for an Application gateway

- Set `zones` to any or all of `["1", "2", "3"]`.
- Set `properties.sku.name` and `properties.sku.tier` to `Standard_v2` or `WAF_v2`.

For example:

```json
  {
    "name": "appGw-001",
    "type": "Microsoft.Network/applicationGateways",
    "apiVersion": "2019-09-01",
    "location": "[resourceGroup().location]",
    "zones": [
      "1",
      "2",
      "3"
    ],
    "tags": {},
    "properties": {
      "sku": {
        "name": "WAF_v2",
        "tier": "WAF_v2"
      },
      "autoscaleConfiguration": {
        "minCapacity": 2,
        "maxCapacity": 3
      }
    }
  }
```

### Configure with Bicep

To set availability zones for an Application gateway

- Set `zones` to any or all of `["1", "2", "3"]`.
- Set `properties.sku.name` and `properties.sku.tier` to `Standard_v2` or `WAF_v2`.

For example:

```bicep
resource name_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: 'appGw-001'
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  tags: {}
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    autoscaleConfiguration: {
      minCapacity: 2
      maxCapacity: 3
    }
  }
}
```

### Configure with Azure CLI

#### Create WAFv2 Application Gateway in Zone 1, 2 and 3

```bash
az network application-gateway create \
  --name '<application_gateway_name>' \
  --location '<location>' \
  --resource-group '<resource_group>' \
  --capacity '<capacity>' \
  --sku WAF_v2 \
  --public-ip-address '<public_ip_address>' \
  --vnet-name '<virtual_network_name>' \
  --subnet '<subnet_name>' \
  --zones 1 2 3 \
  --servers '<address_1>' '<address_2>'
```

## LINKS

- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways?tabs=json)
- [Autoscaling and Zone-redundant Application Gateway v2](https://learn.microsoft.com/azure/application-gateway/application-gateway-autoscaling-zone-redundant)
- [Use zone-aware services](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-best-practices#use-zone-aware-services)
- [Azure Well-Architected Framework - Reliability](https://learn.microsoft.com/azure/architecture/framework/resiliency/)

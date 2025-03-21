---
reviewed: 2024-10-11
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Application Gateway
resourceType: Microsoft.Network/applicationGateways
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.AvailabilityZone/
---

# Application gateways should use Availability zones in supported regions

## SYNOPSIS

Application Gateway (App Gateway) should use availability zones in supported regions for improved resiliency.

## DESCRIPTION

App Gateway V2 (Standard_v2 and WAF_v2) supports the use of availability zones to improve resiliency.
Each Availability Zone is a group of physically separated data centers.

When configured, App Gateway spreads infrastructure instances across multiple availability zones you choose.
When a zone impacting event occurs, Application Gateway is able to continue processing network traffic from other zones.

Key points when configuring availability zones:

- **Configure two (2) or more** &mdash; Configuring only a single zone (zonal) doesn't provide zone redundancy.
  If the configured zone fails, the service fails.
  Ideally, configure three zones. i.e. `1`, `2`, and `3`.
- **Consider the network path and connected services** &mdash; Look along the network path to other services, to match zones.
  If App Gateway is deployed to zones `1` and `2` but your applications backend or firewall is deployed to zone `3`,
  failure of any zone would cause failure of the application.
- **Available regions** &mdash; Availability zones are not available in all Azure regions/ locations.
  To use availability zones, choose regions that support this feature for the Azure services in your application.
- **Supported SKUs** &mdash; Availability zones are not supported with the legacy V1 SKU.
  You must use the `Standard_v2` or `WAF_v2` SKU to configure availability zones.

## RECOMMENDATION

Consider using the Application Gateway V2 SKU and configure at least two (2) availability zones to improve resiliency.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set `zones` to any or all of `["1", "2", "3"]`.
- Set `properties.sku.name` and `properties.sku.tier` to `Standard_v2` or `WAF_v2`.

For example:

```json
{
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2024-01-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "zones": [
    "1",
    "2",
    "3"
  ],
  "properties": {
    "sku": {
      "name": "WAF_v2",
      "tier": "WAF_v2"
    },
    "sslPolicy": {
      "policyType": "Custom",
      "minProtocolVersion": "TLSv1_2",
      "cipherSuites": [
        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
      ]
    },
    "autoscaleConfiguration": {
      "minCapacity": 2,
      "maxCapacity": 3
    },
    "firewallPolicy": {
      "id": "[resourceId('Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'agwwaf')]"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'agwwaf')]"
  ]
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Set `zones` to any or all of `['1', '2', '3']`.
- Set `properties.sku.name` and `properties.sku.tier` to `Standard_v2` or `WAF_v2`.

For example:

```bicep
resource appgw 'Microsoft.Network/applicationGateways@2024-01-01' = {
  name: name
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    sslPolicy: {
      policyType: 'Custom'
      minProtocolVersion: 'TLSv1_2'
      cipherSuites: [
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
      ]
    }
    autoscaleConfiguration: {
      minCapacity: 2
      maxCapacity: 3
    }
    firewallPolicy: {
      id: waf.id
    }
  }
}
```

<!-- external:avm avm/res/network/application-gateway zones,sku -->

### Configure with Azure CLI

#### Create WAFv2 Application Gateway in Zone 1, 2 and 3

To deploy Application Gateways that pass this rule:

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

## NOTES

This rule fails when `"zones"` is `null`, `[]` or not set when the Application gateway is deployed with V2
SKU (Standard_v2, WAF_v2) and there are supported availability zones for the given region.

### Rule configuration

<!-- module:config rule AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST -->

Configure `AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST` to set additional availability zones that need to be
supported which are not in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/tree/main/data/providers/)
for namespace `Microsoft.Network` and resource type `applicationGateways`.

```yaml
# YAML: The default AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [What are availability zones?](https://learn.microsoft.com/azure/reliability/availability-zones-overview)
- [Autoscaling and Zone-redundant Application Gateway v2](https://learn.microsoft.com/azure/application-gateway/application-gateway-autoscaling-zone-redundant)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)

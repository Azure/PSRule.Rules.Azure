---
severity: Critical
pillar: Security
category: Data protection
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.UseHTTPS/
author: BernieWhite
ms-date: 2021/07/25
---

# Expose frontend HTTP endpoints over HTTPS

## SYNOPSIS

Application Gateways should only expose frontend HTTP endpoints over HTTPS.

## DESCRIPTION

Application Gateways support HTTP and HTTPS endpoints for backend and frontend traffic.
When using frontend HTTP (80) endpoints, traffic between client and Application Gateway is not encrypted.

Unencrypted communication could allow disclosure of information to an un-trusted party.

## RECOMMENDATION

Consider configuring Application Gateways to only expose HTTPS endpoints.
For client applications such as progressive web apps, consider redirecting HTTP traffic to HTTPS.

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set the `properties.frontendPorts.properties.port` property to `443`.

Fors example:

```json
{
    "type": "Microsoft.Network/applicationGateways",
    "apiVersion": "2020-11-01",
    "name": "appGw-001",
    "location": "[resourceGroup().location]",
    "properties": {
        "sku": {
            "name": "WAF_v2",
            "tier": "WAF_v2"
        },
        "sslPolicy": {
          "minProtocolVersion": "TLSv1_2"
        },
        "frontendPorts": [
          {
            "name": "https",
            "properties": {
              "Port": 443
            }
          }
        ]
    }
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Set the `properties.frontendPorts.properties.port` property to `443`.

For example:

```bicep
resource name_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: 'appGw-001'
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    sslPolicy: {
      minProtocolVersion: 'TLSv1_2'
    }
    frontendPorts: [
      {
        name: 'https'
        properties: {
          Port: 443
        }
      }
    ]
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Create an application gateway with HTTP to HTTPS redirection using the Azure portal](https://docs.microsoft.com/azure/application-gateway/redirect-http-to-https-portal)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.network/applicationgateways)

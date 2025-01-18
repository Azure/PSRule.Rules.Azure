---
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.UseHTTPS/
---

# Expose frontend HTTP endpoints over HTTPS

## SYNOPSIS

Application Gateways should only expose frontend HTTP endpoints over HTTPS.

## DESCRIPTION

Application Gateways support HTTP and HTTPS endpoints for backend and frontend traffic.
When using frontend HTTP (`80`) endpoints, traffic between client and Application Gateway is not encrypted.

Unencrypted communication could allow disclosure of information to an un-trusted party.

## RECOMMENDATION

Consider configuring Application Gateways to only expose HTTPS endpoints.
For client applications such as progressive web apps, consider redirecting HTTP traffic to HTTPS.

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set the `properties.frontendPorts.properties.port` property to `443`.

For example:

```json
{
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2023-09-01",
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
resource app_gw 'Microsoft.Network/applicationGateways@2023-09-01' = {
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

<!-- external:avm avm/res/network/application-gateway frontendPorts -->

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/application-gateway-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Create an application gateway with HTTP to HTTPS redirection using the Azure portal](https://learn.microsoft.com/azure/application-gateway/redirect-http-to-https-portal)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)

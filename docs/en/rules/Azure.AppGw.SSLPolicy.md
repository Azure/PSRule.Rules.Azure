---
reviewed: 2024-02-24
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Application Gateway
resourceType: Microsoft.Network/applicationGateways
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.SSLPolicy/
---

# Application Gateways use a minimum TLS 1.2

## SYNOPSIS

Application Gateway should only accept a minimum of TLS 1.2.

## DESCRIPTION

The minimum version of TLS that Application Gateways accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

Application Gateway should only accept a minimum of TLS 1.2 to ensure secure connections.

## RECOMMENDATION

Consider configuring Application Gateways to accept a minimum of TLS 1.2.

### Configure with Azure template

To deploy Application Gateways that pass this rule use a predefined or custom policy:

- **Custom** &mdash; Set the `properties.sslPolicy.policyType` property to `Custom`.
  - Set the `properties.sslPolicy.minProtocolVersion` property to `TLSv1_2`.
  - Set the `properties.sslPolicy.cipherSuites` property to a list of supported ciphers. For example:
    - `TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384`
    - `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256`
    - `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`
    - `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`
- **Predefined** &mdash; Set the `properties.sslPolicy.policyType` property to `Predefined`.
  - Set the `properties.sslPolicy.policyName` property to a supported predefined policy such as `AppGwSslPolicy20220101S`.

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
    }
  }
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule use a predefined or custom policy:

- **Custom** &mdash; Set the `properties.sslPolicy.policyType` property to `Custom`.
  - Set the `properties.sslPolicy.minProtocolVersion` property to `TLSv1_2`.
  - Set the `properties.sslPolicy.cipherSuites` property to a list of supported ciphers. For example:
    - `TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384`
    - `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256`
    - `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`
    - `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`
- **Predefined** &mdash; Set the `properties.sslPolicy.policyType` property to `Predefined`.
  - Set the `properties.sslPolicy.policyName` property to a supported predefined policy such as `AppGwSslPolicy20220101S`.

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
  }
}
```

### Configure with Azure PowerShell

```powershell
$gw = Get-AzApplicationGateway -Name '<name>' -ResourceGroupName '<resource_group>'
Set-AzApplicationGatewaySslPolicy -ApplicationGateway $gw -PolicyType Custom -MinProtocolVersion TLSv1_2 -CipherSuite 'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384', 'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256', 'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384', 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/application-gateway-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Application Gateway SSL policy overview](https://learn.microsoft.com/azure/application-gateway/application-gateway-ssl-policy-overview)
- [Configure SSL policy versions and cipher suites on Application Gateway](https://learn.microsoft.com/azure/application-gateway/application-gateway-configure-ssl-policy-powershell)
- [Overview of TLS termination and end to end TLS with Application Gateway](https://learn.microsoft.com/azure/application-gateway/ssl-overview)
- [Predefined TLS policy](https://learn.microsoft.com/azure/application-gateway/application-gateway-ssl-policy-overview#predefined-tls-policy)
- [Cipher suites](https://learn.microsoft.com/azure/application-gateway/application-gateway-ssl-policy-overview#cipher-suites)
- [Limitations](https://learn.microsoft.com/azure/application-gateway/application-gateway-ssl-policy-overview#limitations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)

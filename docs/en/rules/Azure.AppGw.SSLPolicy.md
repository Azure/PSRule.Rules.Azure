---
severity: Critical
pillar: Security
category: Data protection
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.SSLPolicy/
---

# Application Gateways use a minimum TLS 1.2

## SYNOPSIS

Application Gateway should only accept a minimum of TLS 1.2.

## DESCRIPTION

Application Gateway should only accept a minimum of TLS 1.2 to ensure secure connections.

## RECOMMENDATION

Consider configuring Application Gateway to accept a minimum of TLS 1.2.

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set the `properties.sslPolicy.policyType` property to `Custom or Predefined`.
If the `properties.sslPolicy.policyType` is set to `Predefined`, `properties.sslPolicy.policyName`
becomes mandatory whereas, `minProtocolVersion` and `cipherSuites` are not supported.

- For `Custom`, set the `properties.sslPolicy.minProtocolVersion` property to `TLSv1_2` and add list of supported `cipherSuites`.

For example:

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
          "policyType": "Custom",
          "minProtocolVersion": "TLSv1_2",
          "cipherSuites": []
        }
    }
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Set the `properties.sslPolicy.policyType` property to `Custom or Predefined`.
If the `properties.sslPolicy.policyType` is set to `Predefined`, `properties.sslPolicy.policyName`
becomes mandatory whereas, `minProtocolVersion` and `cipherSuites` are not supported.

- For `Custom`, set the `properties.sslPolicy.minProtocolVersion` property to `TLSv1_2` and add list of supported `cipherSuites`.

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
      policyType: 'Custom'
      minProtocolVersion: 'TLSv1_2'
      cipherSuites: []
    }
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Application Gateway SSL policy overview](https://docs.microsoft.com/azure/application-gateway/application-gateway-ssl-policy-overview)
- [Configure SSL policy versions and cipher suites on Application Gateway](https://docs.microsoft.com/azure/application-gateway/application-gateway-configure-ssl-policy-powershell)
- [Overview of TLS termination and end to end TLS with Application Gateway](https://docs.microsoft.com/azure/application-gateway/ssl-overview)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.network/applicationgateways)

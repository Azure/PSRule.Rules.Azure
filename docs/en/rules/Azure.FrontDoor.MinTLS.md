---
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.MinTLS/
---

# Front Door Minimum TLS

## SYNOPSIS

Front Door Classic instances should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Azure Front Door accepts is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Front Door lets you disable outdated protocols and enforce TLS 1.2.
By default, a minimum of TLS 1.2 is enforced.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2 for each endpoint.
This applies to Azure Front Door Classic instances only.

## EXAMPLES

### Configure with Azure template

To deploy a Front Door resource that passes this rule:

- Set each `properties.frontendEndpoints[*].properties.customHttpsConfiguration.minimumTlsVersion` property to `1.2`.

For example:

```json
{
  "type": "Microsoft.Network/frontDoors",
  "apiVersion": "2021-06-01",
  "name": "[parameters('name')]",
  "location": "global",
  "properties": {
    "enabledState": "Enabled",
    "frontendEndpoints": [
      {
        "name": "[variables('frontEndEndpointName')]",
        "properties": {
          "hostName": "[format('{0}.azurefd.net', parameters('name'))]",
          "sessionAffinityEnabledState": "Disabled",
          "customHttpsConfiguration": {
            "minimumTlsVersion": "1.2"
          }
        }
      }
    ],
    "loadBalancingSettings": "[variables('loadBalancingSettings')]",
    "backendPools": "[variables('backendPools')]",
    "healthProbeSettings": "[variables('healthProbeSettings')]",
    "routingRules": "[variables('routingRules')]"
  }
}
```

### Configure with Bicep

To deploy a Front Door resource that passes this rule:

- Set each `properties.frontendEndpoints[*].properties.customHttpsConfiguration.minimumTlsVersion` property to `1.2`.

For example:

```bicep
resource afd_classic 'Microsoft.Network/frontDoors@2021-06-01' = {
  name: name
  location: 'global'
  properties: {
    enabledState: 'Enabled'
    frontendEndpoints: [
      {
        name: frontEndEndpointName
        properties: {
          hostName: '${name}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
          customHttpsConfiguration: {
            minimumTlsVersion: '1.2'
          }
        }
      }
    ]
    loadBalancingSettings: loadBalancingSettings
    backendPools: backendPools
    healthProbeSettings: healthProbeSettings
    routingRules: routingRules
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Supported TLS versions](https://learn.microsoft.com/azure/frontdoor/end-to-end-tls?pivots=front-door-classic#supported-tls-versions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoors/frontendendpoints)

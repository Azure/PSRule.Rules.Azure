---
severity: Important
pillar: Performance Efficiency
category: PE:08 Data performance
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.UseCaching/
---

# Use caching

## SYNOPSIS

Use caching to reduce retrieving contents from origins.

## DESCRIPTION

Azure Front Door delivers large files without a cap on file size.
Front Door uses a technique called object chunking.
When a large file is requested, Front Door retrieves smaller pieces of the file from the backend.
After receiving a full or byte-range file request, the Front Door environment requests the file from the backend in chunks of 8 MB.

After the chunk arrives at the Front Door environment, it's cached and immediately served to the user.
Front Door then pre-fetches the next chunk in parallel.
This pre-fetch ensures that the content stays one chunk ahead of the user, which reduces latency.
This process continues until the entire file gets downloaded (if requested) or the client closes the connection.

For more information on the byte-range request, read RFC 7233.
Front Door caches any chunks as they're received so the entire file doesn't need to be cached on the Front Door cache.
Ensuing requests for the file or byte ranges are served from the cache.
If the chunks aren't all cached, pre-fetching is used to request chunks from the backend.
This optimization relies on the backend's ability to support byte-range requests.
If the backend doesn't support byte-range requests, this optimization isn't effective.

## RECOMMENDATION

Use caching to reduce retrieving contents from origins and improve overall performance.

## EXAMPLES

### Configure with Azure template

To deploy front door instances pass this rule:

- Configure `properties.routingRules.properties.routeConfiguration.cacheConfiguration`.

**Important** The rule checks also for rule sets (child resources) that are overwriting the cache configuration from routing rules.
Check the link `Routing architecture overview` for more information around this.

For example:

```json
{
  "type": "Microsoft.Network/frontDoors",
  "apiVersion": "2021-06-01",
  "name": "[parameters('frontDoorName')]",
  "location": "global",
  "properties": {
    "enabledState": "Enabled",
    "frontendEndpoints": [
      {
        "name": "[variables('frontEndEndpointName')]",
        "properties": {
          "hostName": "[format('{0}.azurefd.net', parameters('frontDoorName'))]",
          "sessionAffinityEnabledState": "Disabled"
        }
      }
    ],
    "loadBalancingSettings": [
      {
        "name": "[variables('loadBalancingSettingsName')]",
        "properties": {
          "sampleSize": 4,
          "successfulSamplesRequired": 2
        }
      }
    ],
    "healthProbeSettings": [
      {
        "name": "[variables('healthProbeSettingsName')]",
        "properties": {
          "path": "/",
          "protocol": "Http",
          "intervalInSeconds": 120
        }
      }
    ],
    "backendPools": [
      {
        "name": "[variables('backendPoolName')]",
        "properties": {
          "backends": [
            {
              "address": "[parameters('backendAddress')]",
              "backendHostHeader": "[parameters('backendAddress')]",
              "httpPort": 80,
              "httpsPort": 443,
              "weight": 50,
              "priority": 1,
              "enabledState": "Enabled"
            }
          ],
          "loadBalancingSettings": {
            "id": "[resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', parameters('frontDoorName'), variables('loadBalancingSettingsName'))]"
          },
          "healthProbeSettings": {
            "id": "[resourceId('Microsoft.Network/frontDoors/healthProbeSettings', parameters('frontDoorName'), variables('healthProbeSettingsName'))]"
          }
        }
      }
    ],
    "routingRules": [
      {
        "name": "[variables('routingRuleName')]",
        "properties": {
          "frontendEndpoints": [
            {
              "id": "[resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', parameters('frontDoorName'), variables('frontEndEndpointName'))]"
            }
          ],
          "acceptedProtocols": [
            "Http",
            "Https"
          ],
          "patternsToMatch": [
            "/*"
          ],
          "routeConfiguration": {
            "@odata.type": "#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration",
            "cacheConfiguration": {
              "cacheDuration": "P12DT1H",
              "dynamicCompression": "Disabled",
              "queryParameters": "customerId",
              "queryParameterStripDirective": "StripAll"
            },
            "forwardingProtocol": "MatchRequest",
            "backendPool": {
              "id": "[resourceId('Microsoft.Network/frontDoors/backEndPools', parameters('frontDoorName'), variables('backendPoolName'))]"
            }
          },
          "enabledState": "Enabled"
        }
      }
    ]
  }
}
```

### Configure with Bicep

To deploy front door instances pass this rule:

- Configure `properties.routingRules.properties.routeConfiguration.cacheConfiguration`.

**Important** The rule checks also for rule sets (child resources) that are overwriting the cache configuration from routing rules.
Check the link `Routing architecture overview` for more information around this.

For example:

```bicep
@description('The name of the Front Door profile.')
param frontDoorName string

@description('The hostname of the backend. Must be an IP address or FQDN.')
param backendAddress string

var frontEndEndpointName = 'frontEndEndpoint'
var loadBalancingSettingsName = 'loadBalancingSettings'
var healthProbeSettingsName = 'healthProbeSettings'
var routingRuleName = 'routingRule'
var backendPoolName = 'backendPool'

resource frontDoor 'Microsoft.Network/frontDoors@2021-06-01' = {
  name: frontDoorName
  location: 'global'
  properties: {
    enabledState: 'Enabled'

    frontendEndpoints: [
      {
        name: frontEndEndpointName
        properties: {
          hostName: '${frontDoorName}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
        }
      }
    ]

    loadBalancingSettings: [
      {
        name: loadBalancingSettingsName
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
    ]

    healthProbeSettings: [
      {
        name: healthProbeSettingsName
        properties: {
          path: '/'
          protocol: 'Http'
          intervalInSeconds: 120
        }
      }
    ]

    backendPools: [
      {
        name: backendPoolName
        properties: {
          backends: [
            {
              address: backendAddress
              backendHostHeader: backendAddress
              httpPort: 80
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, loadBalancingSettingsName)
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, healthProbeSettingsName)
          }
        }
      }
    ]

    routingRules: [
      {
        name: routingRuleName
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, frontEndEndpointName)
            }
          ]
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            cacheConfiguration: {
              cacheDuration: 'P12DT1H'
              dynamicCompression: 'Disabled'
              queryParameters: 'customerId'
              queryParameterStripDirective: 'StripAll'
            }
            forwardingProtocol: 'MatchRequest'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, backendPoolName)
            }
          }
          enabledState: 'Enabled'
        }
      }
    ]
  }
}
```

## NOTES

This rule only applies to Azure Front Door Classic profiles (`Microsoft.Network/frontDoors`).

## LINKS

- [PE:08 Data performance](https://learn.microsoft.com/azure/well-architected/performance-efficiency/optimize-data-performance)
- [Caching with Azure Front Door](https://learn.microsoft.com/azure/frontdoor/front-door-caching)
- [Routing architecture overview](https://learn.microsoft.com/azure/frontdoor/front-door-routing-architecture)
- [Azure deployment reference - Classic Profile](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoors)
- [Azure deployment reference - Classic Rules engine](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoors/rulesengines)

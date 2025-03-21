---
reviewed: 2023-02-18
severity: Important
pillar: Reliability
category: Health modeling
resource: Front Door
resourceType: Microsoft.Network/frontDoors,Microsoft.Network/Frontdoors/HealthProbeSettings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.Probe/
---

# Use Health Probes for Front Door backends

## SYNOPSIS

Use health probes to check the health of each backend.

## DESCRIPTION

The health and performance of an application can degrade over time.
Degradation might not be noticeable until the application fails.

Azure Front Door can use periodic health probes against backend endpoints to determine health status.
When one or more backend in a pool is healthy traffic is routed to healthy endpoints only.
If all endpoints in a pool is unhealthy Front Door sends the request to any enabled endpoint.

Health probes allow Front Door to select a backend endpoint able to respond to the request.

## RECOMMENDATION

Consider configuring and enabling a health probe for each Front Door backend.

## EXAMPLES

### Configure with Azure template

=== "Premium / Standard"

    To deploy a Front Door resource that passes this rule:

    - Configure the `properties.healthProbeSettings` property of the `originGroups` sub-resource.

    For example:

    ```json
    {
      "type": "Microsoft.Cdn/profiles",
      "apiVersion": "2021-06-01",
      "name": "[parameters('name')]",
      "location": "Global",
      "sku": {
        "name": "Premium_AzureFrontDoor"
      }
    },
    {
      "type": "Microsoft.Cdn/profiles/originGroups",
      "apiVersion": "2021-06-01",
      "name": "[format('{0}/{1}', parameters('name'), parameters('name'))]",
      "properties": {
        "loadBalancingSettings": {
          "sampleSize": 4,
          "successfulSamplesRequired": 3
        },
        "healthProbeSettings": {
          "probePath": "/healthz",
          "probeRequestType": "HEAD",
          "probeProtocol": "Http",
          "probeIntervalInSeconds": 100
        }
      },
      "dependsOn": [
        "[parameters('name')]"
      ]
    }
    ```

=== "Classic"

    To deploy a Front Door resource that passes this rule:

    - Set each `properties.healthProbeSettings[*].properties.enabledState` property to `Enabled`.

    For example:

    ```json
    {
      "type": "Microsoft.Network/frontDoors",
      "apiVersion": "2021-06-01",
      "name": "[parameters('name')]",
      "location": "global",
      "properties": {
        "enabledState": "Enabled",
        "frontendEndpoints": "[variables('frontendEndpoints')]",
        "loadBalancingSettings": "[variables('loadBalancingSettings')]",
        "backendPools": "[variables('backendPools')]",
        "healthProbeSettings": [
          {
            "name": "[variables('healthProbeSettingsName')]",
            "properties": {
              "enabledState": "Enabled",
              "path": "/healthz",
              "protocol": "Http",
              "intervalInSeconds": 120,
              "healthProbeMethod": "HEAD"
            }
          }
        ],
        "routingRules": "[variables('routingRules')]"
      }
    }
    ```

### Configure with Bicep

=== "Premium / Standard"

    To deploy a Front Door resource that passes this rule:

    - Configure the `properties.healthProbeSettings` property of the `originGroups` sub-resource.

    For example:

    ```bicep
    resource afd_premium 'Microsoft.Cdn/profiles@2021-06-01' = {
      name: name
      location: 'Global'
      sku: {
        name: 'Premium_AzureFrontDoor'
      }
    }

    resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
      name: name
      parent: afd_premium
      properties: {
        loadBalancingSettings: {
          sampleSize: 4
          successfulSamplesRequired: 3
        }
        healthProbeSettings: {
          probePath: '/healthz'
          probeRequestType: 'HEAD'
          probeProtocol: 'Http'
          probeIntervalInSeconds: 100
        }
      }
    }
    ```

=== "Classic"

    To deploy a Front Door resource that passes this rule:

    - Set each `properties.healthProbeSettings[*].properties.enabledState` property to `Enabled`.

    For example:

    ```bicep
    resource afd_classic 'Microsoft.Network/frontDoors@2021-06-01' = {
      name: name
      location: 'global'
      properties: {
        enabledState: 'Enabled'
        frontendEndpoints: frontendEndpoints
        loadBalancingSettings: loadBalancingSettings
        backendPools: backendPools
        healthProbeSettings: [
          {
            name: healthProbeSettingsName
            properties: {
              enabledState: 'Enabled'
              path: '/healthz'
              protocol: 'Http'
              intervalInSeconds: 120
              healthProbeMethod: 'HEAD'
            }
          }
        ]
        routingRules: routingRules
      }
    }
    ```

### Configure with Azure CLI

```bash
az network front-door probe update --front-door-name '<front_door>' -n '<probe_name>' -g '<resource_group>' --enabled 'Enabled' --path '/healthz'
```

### Configure with Azure PowerShell

```powershell
$probeSetting = New-AzFrontDoorHealthProbeSettingObject -Name '<probe_name>' -EnabledState 'Enabled' -Path '/healthz'
Set-AzFrontDoor -Name '<front_door>' -ResourceGroupName '<resource_group>' -HealthProbeSetting $probeSetting
```

## LINKS

- [Creating good health probes](https://learn.microsoft.com/azure/architecture/framework/resiliency/monitor-model#create-good-health-probes)
- [Health probes](https://learn.microsoft.com/azure/frontdoor/front-door-health-probes)
- [Supported HTTP methods for health probes](https://learn.microsoft.com/azure/frontdoor/health-probes#supported-http-methods-for-health-probes)
- [How Front Door determines backend health](https://learn.microsoft.com/azure/frontdoor/health-probes#how-front-door-determines-backend-health)
- [Health Endpoint Monitoring pattern](https://learn.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
- [Azure deployment reference (Premium / Standard)](https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/origingroups)
- [Azure deployment reference (Classic)](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoors#HealthProbeSettingsProperties)

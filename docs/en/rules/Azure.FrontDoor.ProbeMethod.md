---
reviewed: 2023-02-18
severity: Important
pillar: Reliability
category: Health modeling
resource: Front Door
resourceType: Microsoft.Network/frontDoors,Microsoft.Network/Frontdoors/HealthProbeSettings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.ProbeMethod/
---

# Use HEAD health probes for Front Door backends

## SYNOPSIS

Configure health probes to use `HEAD` requests to reduce performance overhead.

## DESCRIPTION

Azure Front Door supports sending `HEAD` or `GET` requests for health probes to backend endpoints.
HTTP `HEAD` requests are identical to `GET` requests except that the server does not send a response body.
As a result, `HEAD` request typically have a lower performance impact then `GET` request.

By eliminating a response body:

- The server has a smaller payload to return.
- May be able to further optimize the request by reducing calls to APIs or databases.

## RECOMMENDATION

Consider configuring health probes to query backend health endpoints using `HEAD` requests to reduce performance overhead.

## EXAMPLES

### Configure with Azure template

=== "Premium / Standard"

    To deploy a Front Door resource that passes this rule:

    - Set the `properties.healthProbeSettings.probeRequestType` property to `HEAD` of the `originGroups` sub-resource.

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

    - Set each `properties.healthProbeSettings[*].properties.healthProbeMethod` property to `HEAD`.

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

    - Set the `properties.healthProbeSettings.probeRequestType` property to `HEAD` of the `originGroups` sub-resource.

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

    - Set each `properties.healthProbeSettings[*].properties.healthProbeMethod` property to `HEAD`.

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
az network front-door probe update --front-door-name '<front_door>' -n '<probe_name>' -g '<resource_group>' --probeMethod 'HEAD' --path '/healthz'
```

### Configure with Azure PowerShell

```powershell
$probeSetting = New-AzFrontDoorHealthProbeSettingObject -Name '<probe_name>' -HealthProbeMethod 'HEAD' -Path '/healthz'
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

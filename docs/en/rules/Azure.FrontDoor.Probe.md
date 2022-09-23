---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.Probe/
---

# Use Health Probes for Front Door backends

## SYNOPSIS

Configure and enable health probes for each backend pool.

## DESCRIPTION

The health and performance of an application can degrade over time.
Degradation might not be noticeable until the application fails.

Azure Front Door can use periodic health probes against backend endpoints to determine health status.
When one or more backend in a pool is healthy traffic is routed to healthy endpoints only.
If all endpoints in a pool is unhealthy Front Door sends the request to any enabled endpoint.

Health probes allow Front Door to select a backend endpoint able to respond to the request.

## RECOMMENDATION

Consider enabling a health probe for each Front Door backend endpoint.

## EXAMPLES

### Configure with Azure CLI

```bash
az network front-door probe update --front-door-name '<front_door>' -n '<probe_name>' -g '<resource_group>' --enabled 'Enabled'
```

### Configure with Azure PowerShell

```powershell
$probeSetting = New-AzFrontDoorHealthProbeSettingObject -Name '<probe_name>' -EnabledState 'Enabled'
Set-AzFrontDoor -Name '<front_door>' -ResourceGroupName '<resource_group>' -HealthProbeSetting $probeSetting
```
### Configure with Azure PowerShell

```powershell
$probeSetting = New-AzFrontDoorHealthProbeSettingObject -Name '<probe_name>' -Path '<path>'
Set-AzFrontDoor -Name '<front_door>' -ResourceGroupName '<resource_group>' -HealthProbeSetting $probeSetting
```

### Configure with Azure template

To deploy a Front Door resource that passes this rule:

- Configure the healthProbeSettings on the OriginGroup

For example:

```json
  "resources": [
    {
      "type": "Microsoft.Cdn/profiles",
      "apiVersion": "2021-06-01",
      "name": "[parameters('frontDoorName')]",
      "location": "Global",
      "sku": {
        "name": "Standard_AzureFrontDoor"
      }
    },
    {
      "type": "Microsoft.Cdn/profiles/afdEndpoints",
      "apiVersion": "2021-06-01",
      "name": "[format('{0}/{1}', parameters('frontDoorName'), variables('frontDoorEndpointName'))]",
      "location": "Global",
      "properties": {
        "enabledState": "Enabled"
      },
      "dependsOn": [
        "[resourceId('Microsoft.Cdn/profiles', parameters('frontDoorName'))]"
      ]
    },
    {
      "type": "Microsoft.Cdn/profiles/originGroups",
      "apiVersion": "2021-06-01",
      "name": "[format('{0}/{1}', parameters('frontDoorName'), variables('frontDoorDefaultOriginGroupName'))]",
      "properties": {
        "loadBalancingSettings": {
          "sampleSize": 4,
          "successfulSamplesRequired": 3
        },
        "healthProbeSettings": {
          "probePath": "/",
          "probeRequestType": "HEAD",
          "probeProtocol": "Http",
          "probeIntervalInSeconds": 100
        }
      },
      "dependsOn": [
        "[resourceId('Microsoft.Cdn/profiles', parameters('frontDoorName'))]"
      ]
    }
  ]
  ```

### Configure with Bicep

To deploy a Front Door resource that passes this rule:

- Configure the healthProbeSettings on the OriginGroup

For example:

```bicep
resource frontDoorResource 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorName
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: frontDoorResource
  name: frontDoorEndpointName
  location: 'Global'
  properties: {
    enabledState: 'Enabled' 
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  name: frontDoorDefaultOriginGroupName
  parent: frontDoorResource
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}
```

## LINKS

- [Creating good health probes](https://docs.microsoft.com/azure/architecture/framework/resiliency/monitor-model#create-good-health-probes)
- [Health probes](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes)
- [How Front Door determines backend health](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes#how-front-door-determines-backend-health)
- [Health Endpoint Monitoring pattern](https://docs.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
- [Azure resource template](https://docs.microsoft.com/azure/templates/microsoft.network/frontdoors#HealthProbeSettingsProperties)

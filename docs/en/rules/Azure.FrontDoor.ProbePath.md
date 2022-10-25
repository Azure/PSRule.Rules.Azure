---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.ProbePath/
---

# Use a Dedicated Health Endpoint for Front Door backends

## SYNOPSIS

Configure a dedicated path for health probe requests.

## DESCRIPTION

Azure Front Door monitors a specific path for each backend to determine health status.
The monitored path should implement functional checks to determine if the backend is performing correctly.
The checks should include dependencies including those that may not be regularly called.

Regular checks of the monitored path allow Front Door to make load balancing decisions based on status.

## RECOMMENDATION

Consider using a dedicated health probe endpoint that implements functional checks.

## EXAMPLES

### Configure with Azure CLI

```bash
az network front-door probe update --front-door-name '<front_door>' -n '<probe_name>' -g '<resource_group>' --path '<path>'
```

### Configure with Azure PowerShell

```powershell
$probeSetting = New-AzFrontDoorHealthProbeSettingObject -Name '<probe_name>' -Path '<path>'
Set-AzFrontDoor -Name '<front_door>' -ResourceGroupName '<resource_group>' -HealthProbeSetting $probeSetting
```

### Configure with Azure template

To deploy a Front Door resource that passes this rule:

- Configure the healthProbeSettings.probePath on the OriginGroup

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

- Configure the healthProbeSettings.probePath on the OriginGroup

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

- [Health probes](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes)
- [How Front Door determines backend health](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes#how-front-door-determines-backend-health)
- [Creating good health probes](https://learn.microsoft.com/azure/architecture/framework/resiliency/monitoring#creating-good-health-probes)
- [Health Endpoint Monitoring pattern](https://docs.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
- [Azure resource template](https://docs.microsoft.com/azure/templates/microsoft.network/frontdoors#HealthProbeSettingsProperties)

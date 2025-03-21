---
reviewed: 2024-06-18
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Container App
resourceType: Microsoft.App/managedEnvironments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.PublicAccess/
---

# Disable public access

## SYNOPSIS

Ensure public network access for Container Apps environment is disabled.

## DESCRIPTION

Container apps environments allows you to expose your container app to the Internet.

Container apps environments deployed as external resources are available for public requests.
External environments are deployed with a virtual IP on an external, public facing IP address.

Disable public network access to improve security by exposing the Container Apps environment through an internal load balancer.

This removes the need for a public IP address and prevents internet access to all Container Apps within the environment.

To provide secure access externally, instead consider using:

- An Application Gateway in front of your Container Apps using your private VNET.
- A Azure Front Door premium profile with private link to your Container Apps.
  This currently only applies to Container Apps using consumption without workload profiles.

## RECOMMENDATION

Consider disabling public network access by deploying an internal-only container apps to reduce the attack surface.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps environments that pass this rule:

- Set a custom VNET by configuring `properties.vnetConfiguration.infrastructureSubnetId` with the resource Id of a subnet.
- Set `properties.vnetConfiguration.internal` to `true`.

For example:

```json
{
  "type": "Microsoft.App/managedEnvironments",
  "apiVersion": "2024-03-01",
  "name": "[parameters('envName')]",
  "location": "[parameters('location')]",
  "properties": {
    "appLogsConfiguration": {
      "destination": "log-analytics",
      "logAnalyticsConfiguration": {
        "customerId": "[reference(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceId')), '2022-10-01').customerId]",
        "sharedKey": "[listKeys(resourceId('Microsoft.OperationalInsights/workspaces', parameters('workspaceId')), '2022-10-01').primarySharedKey]"
      }
    },
    "zoneRedundant": true,
    "workloadProfiles": [
      {
        "name": "Consumption",
        "workloadProfileType": "Consumption"
      }
    ],
    "vnetConfiguration": {
      "infrastructureSubnetId": "[parameters('subnetId')]",
      "internal": true
    }
  }
}
```

### Configure with Bicep

To deploy Container Apps environments that pass this rule:

- Set a custom VNET by configuring `properties.vnetConfiguration.infrastructureSubnetId` with the resource Id of a subnet.
- Set `properties.vnetConfiguration.internal` to `true`.

For example:

```bicep
resource containerEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: envName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace.properties.customerId
        sharedKey: workspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: true
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    vnetConfiguration: {
      infrastructureSubnetId: subnetId
      internal: true
    }
  }
}
```

<!-- external:avm avm/res/app/managed-environment:0.8.0 infrastructureSubnetId,internal -->

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-container-apps-security-baseline)
- [Networking in Azure Container Apps environment](https://learn.microsoft.com/azure/container-apps/networking)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/managedenvironments#vnetconfiguration)

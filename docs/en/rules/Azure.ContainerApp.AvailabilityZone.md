---
reviewed: 2024-10-01
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.AvailabilityZone/
---

# Use zone redundant Container App environments

## SYNOPSIS

Use Container Apps environments that are zone redundant to improve reliability.

## DESCRIPTION

Container App environments can be configured to be zone redundant in regions that support availability zones.
Zone redundancy is supported in both the workload profiles and consumption only environments.
When configured, replicas of each Container App are spread across availability zones automatically.
A Container App must have multiple replicas to be zone redundant.

For example:

- If a Container App has three replicas, each replica is placed in a different availability zone.
- If a Container App has one replica, it is only available in a single zone.

Zone redundancy can only be enabled at initial environment creation.
Additionally, the Container App environment must be deployed with an infrastructure subnet configured.

## RECOMMENDATION

Consider configuring Container App environments to be zone redundant to improve workload resiliency.

## EXAMPLES

### Configure with Azure template

To deploy Container App environments that pass this rule:

- Set the `properties.zoneRedundant` property to `true`.
- Set the `properties.vnetConfiguration.infrastructureSubnetId` property to reference a valid subnet.

For example:

```json
{
  "type": "Microsoft.App/managedEnvironments",
  "apiVersion": "2023-05-01",
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

To deploy Container App environments that pass this rule:

- Set the `properties.zoneRedundant` property to `true`.
- Set the `properties.vnetConfiguration.infrastructureSubnetId` property to reference a valid subnet.

For example:

```bicep
resource containerEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
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

<!-- external:avm avm/res/app/managed-environment:0.8.0 zoneRedundant,vnetConfiguration.infrastructureSubnetId -->

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Reliability in Azure Container Apps](https://learn.microsoft.com/azure/reliability/reliability-azure-container-apps#availability-zone-support)
- [What are availability zones?](https://learn.microsoft.com/azure/reliability/availability-zones-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)

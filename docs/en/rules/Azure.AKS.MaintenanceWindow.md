---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.MaintenanceWindow/
---

# Customer-controlled maintenance window configuration

## SYNOPSIS

Configure customer-controlled maintenance windows for AKS clusters.

## DESCRIPTION

AKS clusters undergo periodic maintenance automatically to ensure your applications remains secure, stable, and up-to-date. This maintenance includes applying security updates, system upgrades, and software patches.

There are two types of maintenance operations:

- AKS-Initiated Maintenance: Weekly updates that keep your cluster equipped with the latest features and fixes, primarily targeting AKS-specific components.
- User-Initiated Maintenance: Includes cluster auto-upgrades and automatic security updates for node operating systems (OS).

Three schedule configuration types are available for customer-controlled maintenance:

- `default` is a basic configuration for controlling AKS releases. The releases can take up to two weeks to roll out to all regions from the initial time of shipping, because of Azure safe deployment practices. 
 - Maps to the `cluster auto-upgrade channel`, changing the default cadence in the channel.

- `aksManagedAutoUpgradeSchedule` controls when to perform cluster upgrades scheduled by your designated auto-upgrade channel. You can configure more finely controlled cadence and recurrence settings with this configuration compared to the default configuration.
  -  Maps to the `cluster auto-upgrade channel`, changing the default cadence in the channel.

- `aksManagedAutoUpgradeSchedule` controls when to perform cluster upgrades scheduled by your designated auto-upgrade channel. You can configure more finely controlled cadence and recurrence settings with this configuration compared to the default configuration.
  -  Maps to the `node OS auto-upgrade channel`, changing the default cadence in the channel.

The recommended approach is to use `aksManagedAutoUpgradeSchedule` for all cluster upgrade scenarios and `aksManagedNodeOSUpgradeSchedule` for all node OS security patching scenarios.

## RECOMMENDATION

Consider using the customer-controlled maintenance windows 'aksManagedAutoUpgradeSchedule' for all cluster upgrade scenarios and 'aksManagedNodeOSUpgradeSchedule' for all node OS security patching scenarios.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Deploy two maintenance configurations.
 - Set the `name` to `aksManagedAutoUpgradeSchedule` and `aksManagedNodeOSUpgradeSchedule`.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2024-03-02-preview",
  "name": "[parameters('clusterName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Basic",
    "tier": "Standard"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "autoUpgradeProfile": {
      "upgradeChannel": "stable",
      "nodeOSUpgradeChannel": "NodeImage"
    },
    "dnsPrefix": "[parameters('dnsPrefix')]",
    "agentPoolProfiles": [
      {
        "name": "agentpool",
        "osDiskSizeGB": "[parameters('osDiskSizeGB')]",
        "count": "[parameters('agentCount')]",
        "vmSize": "[parameters('agentVMSize')]",
        "osType": "Linux",
        "mode": "System"
      }
    ],
    "linuxProfile": {
      "adminUsername": "[parameters('linuxAdminUsername')]",
      "ssh": {
        "publicKeys": [
          {
            "keyData": "[parameters('sshRSAPublicKey')]"
          }
        ]
      }
    }
  }
},
{
  "type": "Microsoft.ContainerService/managedClusters/maintenanceConfigurations",
  "apiVersion": "2024-03-02-preview",
  "name": "[format('{0}/{1}', parameters('clusterName'), 'aksManagedAutoUpgradeSchedule')]",
  "properties": {
    "maintenanceWindow": {
      "schedule": {
        "weekly": {
          "intervalWeeks": 1,
          "dayOfWeek": "Sunday"
        }
      },
      "durationHours": 4,
      "utcOffset": "+00:00",
      "startDate": "2024-07-15",
      "startTime": "00:00"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName'))]"
  ]
},
{
  "type": "Microsoft.ContainerService/managedClusters/maintenanceConfigurations",
  "apiVersion": "2024-03-02-preview",
  "name": "[format('{0}/{1}', parameters('clusterName'), 'aksManagedNodeOSUpgradeSchedule')]",
  "properties": {
    "maintenanceWindow": {
      "schedule": {
        "weekly": {
          "intervalWeeks": 1,
          "dayOfWeek": "Sunday"
        }
      },
      "durationHours": 4,
      "utcOffset": "+00:00",
      "startDate": "2024-07-15",
      "startTime": "00:00"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName'))]"
  ]
}
```

### Configure with Bicep

To deploy AKS clusters that pass this rule:

- Deploy two maintenance configurations.
 - Set the `name` to `aksManagedAutoUpgradeSchedule` and `aksManagedNodeOSUpgradeSchedule`.

For example:

```bicep
resource aks 'Microsoft.ContainerService/managedClusters@2024-03-02-preview' = {
  name: clusterName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
      nodeOSUpgradeChannel: 'NodeImage'
    }
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}

resource aksManagedAutoUpgradeSchedule 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2024-03-02-preview' = {
  parent: aks
  name: 'aksManagedAutoUpgradeSchedule'
  properties: {
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: 'Sunday'
        }
      }
      durationHours: 4
      utcOffset: '+00:00'
      startDate: '2024-07-15'
      startTime: '00:00'
    }
  }
}

resource aksManagedNodeOSUpgradeSchedule 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2024-03-02-preview' = {
  parent: aks
  name: 'aksManagedNodeOSUpgradeSchedule'
  properties: {
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: 'Sunday'
        }
      }
      durationHours: 4
      utcOffset: '+00:00'
      startDate: '2024-07-15'
      startTime: '00:00'
    }
  }
}
``` 

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Planned maintenance to schedule and control upgrades](https://learn.microsoft.com/azure/aks/planned-maintenance)
- [Patch and upgrade guidance](https://learn.microsoft.com/azure/architecture/operator-guides/aks/aks-upgrade-practices)
- [Create a maintenance window](https://learn.microsoft.com/azure/aks/planned-maintenance#create-a-maintenance-window)
- [Upgrade options](https://learn.microsoft.com/azure/aks/upgrade-cluster)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters/maintenanceconfigurations)

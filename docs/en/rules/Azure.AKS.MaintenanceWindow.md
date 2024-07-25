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

AKS clusters undergo periodic maintenance automatically to ensure your applications remains secure, stable, and up-to-date.
This maintenance includes applying security updates, system upgrades, and software patches.

During peak load times, AKS clusters or workloads may already be scaled to their configured maximums or under stress.
As a result, rescheduling pods, or upgrading a node may take longer then normal.

Maintenance configurations provide a best-effort option that allows you to schedule planned maintenance operations to a predefined window.
This provides greater predictability over cluster operations so that maintenance during peak load times can be avoided when possible.
Noting that some critical or urgent maintenance operations may be performed outside the configured maintenance window.

AKS provides three (3) schedule configuration types are available for customer-controlled maintenance:

- `default` is a basic configuration for controlling AKS weekly releases.
- `aksManagedAutoUpgradeSchedule` controls when to schedule AKS Kubernetes version upgrades.
  This configuration affects the schedule for when cluster auto-upgrades are applied based on your configured channel.
- `aksManagedNodeOSUpgradeSchedule` controls when to schedule AKS node OS upgrades.
  This configuration affects the schedule for when AKS node OS auto-upgrades are applied based on your configured channel.

To read more about automated maintenance operations in AKS see the reference links below.

## RECOMMENDATION

Consider using a planned maintenance windows for AKS and node OS upgrades to avoid periods of high cluster utilization for improved reliability.
Do this by configuring the `aksManagedAutoUpgradeSchedule` and `aksManagedNodeOSUpgradeSchedule` maintenance configurations.

## EXAMPLES

### Configure with Azure template

- Deploy maintenance configurations for cluster version and node OS auto-upgrades.
  - For cluster version auto-upgrades, set the `name` property to `aksManagedAutoUpgradeSchedule`.
  - For node OS auto-upgrades, set the `name` property to `aksManagedNodeOSUpgradeSchedule`.

For cluster version auto-upgrades see the example:

```json
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
}
```

For node OS auto-upgrades see the example:

```json
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

- Deploy maintenance configurations for cluster version and node OS auto-upgrades.
  - For cluster version auto-upgrades, set the `name` property to `aksManagedAutoUpgradeSchedule`.
  - For node OS auto-upgrades, set the `name` property to `aksManagedNodeOSUpgradeSchedule`.

For cluster version auto-upgrades see the example:

```bicep
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
```

For node OS auto-upgrades see the example:

```bicep
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
- [Automatically upgrade an Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/azure/aks/auto-upgrade-cluster)
- [Auto-upgrade node OS images](https://learn.microsoft.com/azure/aks/auto-upgrade-node-os-image)
- [Patch and upgrade guidance](https://learn.microsoft.com/azure/architecture/operator-guides/aks/aks-upgrade-practices)
- [Create a maintenance window](https://learn.microsoft.com/azure/aks/planned-maintenance#create-a-maintenance-window)
- [Upgrade options](https://learn.microsoft.com/azure/aks/upgrade-cluster)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters/maintenanceconfigurations)

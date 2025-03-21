---
reviewed: 2024-06-18
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Azure Virtual Desktop
resourceType: Microsoft.DesktopVirtualization/hostPools
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AVD.ScheduleAgentUpdate/
---

# Schedule agent updates for host pools

## SYNOPSIS

Define a windows for agent updates to minimize disruptions to users.

## DESCRIPTION

Azure Virtual Desktop (AVD) regularly provide updates to the agent software that runs on host pools.
The agent software is responsible for managing user sessions and providing access to resources.
These updates provide new functionality and fixes.
While the update process is designed to minimize disruptions, updates should be applied outside of peak load times.

By default, agent updates are applied automatically when they become available.
If you have configured a maintenance window, updates are only applied during the maintenance window that you specify.
Each host pool can configure up to two maintenance windows per week.

## RECOMMENDATION

Consider defining a maintenance window for agent updates to minimize disruptions to users on AVD host pools.

## EXAMPLES

### Configure with Azure template

To deploy host pools that pass this rule:

- Set the `properties.agentUpdate.type` property to `Scheduled`. _AND_
- Configure one or more maintenance windows in the `properties.agentUpdate.maintenanceWindows` property.

For example:

```json
{
  "type": "Microsoft.DesktopVirtualization/hostPools",
  "apiVersion": "2024-04-03",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "hostPoolType": "Pooled",
    "loadBalancerType": "DepthFirst",
    "preferredAppGroupType": "Desktop",
    "maxSessionLimit": 10,
    "agentUpdate": {
      "type": "Scheduled",
      "maintenanceWindowTimeZone": "AUS Eastern Standard Time",
      "maintenanceWindows": [
        {
          "dayOfWeek": "Sunday",
          "hour": 1
        }
      ]
    }
  }
}
```

### Configure with Bicep

To deploy host pools that pass this rule:

- Set the `properties.agentUpdate.type` property to `Scheduled`. _AND_
- Configure one or more maintenance windows in the `properties.agentUpdate.maintenanceWindows` property.

For example:

```bicep
resource pool 'Microsoft.DesktopVirtualization/hostPools@2024-04-03' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'DepthFirst'
    preferredAppGroupType: 'Desktop'
    maxSessionLimit: 10
    agentUpdate: {
      type: 'Scheduled'
      maintenanceWindowTimeZone: 'AUS Eastern Standard Time'
      maintenanceWindows: [
        {
          dayOfWeek: 'Sunday'
          hour: 1
        }
      ]
    }
  }
}
```

<!-- external:avm avm/res/desktop-virtualization/host-pool agentUpdate -->

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Get started with the Azure Virtual Desktop Agent](https://learn.microsoft.com/azure/virtual-desktop/agent-overview#agent-update-process)
- [Scheduled Agent Updates for Azure Virtual Desktop host pools](https://learn.microsoft.com/azure/virtual-desktop/scheduled-agent-updates)
- [What's new in the Azure Virtual Desktop Agent?](https://learn.microsoft.com/azure/virtual-desktop/whats-new-agent)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.desktopvirtualization/hostpools)

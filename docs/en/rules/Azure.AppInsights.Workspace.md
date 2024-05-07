---
reviewed: 2024-04-29
severity: Important
pillar: Operational Excellence
category: OE:07 Monitoring system
resource: Application Insights
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppInsights.Workspace/
---

# Use workspace-based App Insights resources

## SYNOPSIS

Configure Application Insights resources to store data in a workspace.

## DESCRIPTION

Application Insights (App Insights) can be deployed as either classic or workspace-based resources.
When configured as workspace-based, telemetry is sent from App Insights to a common Log Analytics workspace.
New App Insights resources must have a workspace configured during initial deployment.

Using a Log Analytics workspace for App Insights:

- Makes it easier to correlate issues and query across application components.
- Adds support for additional features of Log Analytics workspaces including:
  - Customer-Managed Keys (CMK).
  - Support for Azure Private Link.
  - Capacity Reservation tiers.
  - Faster data ingestion.

!!! Warning "Classic App Insights resources are retired"
    Classic App Insights resources are were retired on the [29 February 2024][1].
    Consider migrating to workspace-based resources.

  [1]:https://azure.microsoft.com/updates/we-re-retiring-classic-application-insights-on-29-february-2024/

## RECOMMENDATION

Consider using workspace-based Application Insights resources to collect telemetry in shared storage.

## EXAMPLES

### Configure with Azure template

To deploy Application Insights resources that pass this rule:

- Set the `properties.WorkspaceResourceId` property to a valid Log Analytics workspace.

For example:

```json
{
  "type": "microsoft.insights/components",
  "apiVersion": "2020-02-02",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "kind": "web",
  "properties": {
    "Application_Type": "web",
    "Flow_Type": "Redfield",
    "Request_Source": "IbizaAIExtension",
    "WorkspaceResourceId": "[parameters('workspaceId')]"
  }
}
```

### Configure with Bicep

To deploy Application Insights resources that pass this rule:

- Set the `properties.WorkspaceResourceId` property to a valid Log Analytics workspace.

For example:

```bicep
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    WorkspaceResourceId: workspaceId
  }
}
```

<!-- external:avm avm/res/insights/component workspaceResourceId -->

## LINKS

- [OE:07 Monitoring system](https://learn.microsoft.com/azure/well-architected/operational-excellence/observability)
- [Migrate to workspace-based Application Insights resources](https://learn.microsoft.com/azure/azure-monitor/app/convert-classic-resource)
- [We're retiring Classic Application Insights on 29 February 2024][1]
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/components)

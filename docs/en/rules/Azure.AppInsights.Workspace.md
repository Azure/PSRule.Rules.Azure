---
reviewed: 2021-12-20
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Application Insights
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppInsights.Workspace/
---

# Use workspace-based App Insights resources

## SYNOPSIS

Configure Application Insights resources to store data in workspaces.

## DESCRIPTION

Application Insights (App Insights) can be deployed as either classic or workspace-based resources.
When configured as workspace-based, telemetry is sent from App Insights to a common Log Analytics workspace.

Using a Log Analytics workspace for App Insights:

- Makes it easier to query across applications.
- Adds support for additional features of Log Analytics workspaces including:
  - Customer-Managed Keys (CMK).
  - Support for Azure Private Link.
  - Capacity Reservation tiers.
  - Faster data ingestion.

App Insights resources can be configured as workspace-based either during or after initial deployment.

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

## LINKS

- [Collection and storage](https://learn.microsoft.com/azure/architecture/framework/devops/monitor-collection-data-storage)
- [Migrate to workspace-based Application Insights resources](https://docs.microsoft.com/azure/azure-monitor/app/convert-classic-resource)
- [Azure resource template](https://docs.microsoft.com/azure/templates/microsoft.insights/components#applicationinsightscomponentproperties-object)

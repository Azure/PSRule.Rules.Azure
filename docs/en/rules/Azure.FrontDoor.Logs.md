---
severity: Important
pillar: Security
category: Security operations
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.Logs/
---

# Audit Front Door access

## SYNOPSIS

Audit and monitor access through Front Door.

## DESCRIPTION

To capture network activity through Front Door, diagnostic settings must be configured.
When configuring diagnostics settings enable `FrontdoorAccessLog` logs.

Enable `FrontdoorWebApplicationFirewallLog` when web application firewall (WAF) policy is configured.

Management operations for Front Door is captured automatically within Azure Activity Logs.

## RECOMMENDATION

Consider configuring diagnostics setting to log network activity through Front Door.

## EXAMPLES

<!-- 
### Configure with Azure template

To deploy Front Door that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for the `AuditEvent` category.

For example:

```json
{
    "coming soon once Bicep compiles and deploys...",

}
```
-->

---

### Configure Manually

To deploy Front Door that passes this rule:

- Deploy a diagnostic settings sub-resource.
- Manually go into the diagnostic settings and add these two rules:
  - Enable logging for the `FrontdoorAccessLog` category.
  - Enable logging for the `FrontdoorWebApplicationFirewallLog` category.

---

### Configure with Azure template

If this setting was available in Bicep, it could be set like the following Bicep shows. 

#### Bicep Template

```bicep
param frontDoorName string = 'myFrontDoor'
param workSpaceId string = ''
param location string = resourceGroup().location

resource frontDoorResource 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorName
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

resource frontDoorInsightsResource 'Microsoft.Cdn/profiles/providers/diagnosticSettings@2020-01-01-preview' = {
  name: '${frontDoorName}/Microsoft.Insights/service'
  dependsOn: [
    frontDoorResource
  ]
  location: location
  properties: {
    workspaceId: workSpaceId
    logs: [
      {
        category: 'FrontdoorAccessLog'
        enabled: true
      }
      {
        category: 'FrontdoorWebApplicationFirewallLog'
        enabled: true
      }
    ]
  }
}
```

---

#### Test Script

Deploy Test Script: For debugging purposes, save the bicep above to sampleFrontDoor.bicep and run this command to test the deploy of this template:

```ps1
az deployment group create -n front-door-test-20220919T150200Z --resource-group rg_sandbox --template-file 'sampleFrontDoor.bicep' --parameters frontDoorName=yourFrontDoorName workSpaceId=/subscriptions/yourSubscriptionId/resourcegroups/yourResourceGroup/providers/microsoft.operationalinsights/workspaces/yourLogAnalyticsWorkspaceName
```

#### Errors

However, this Bicep fails and gets the following error, so I can't figure out how to deploy this setting via ARM/Bicep.
All the docs  say to do this manually... I can't find how to automate this setting!

```bicep
'.../resourcegroups/myResourceGroupName/providers/Microsoft.Cdn/profiles/myFrontDoorName/providers/Microsoft.Insights/diagnosticSettings/service' is not supported"
```

---

## LINKS

- [Monitoring metrics and logs in Azure Front Door Service](https://docs.microsoft.com/azure/frontdoor/front-door-diagnostics#diagnostic-logging)
- [Create a Front Door Standard/Premium using Bicep](https://learn.microsoft.com/en-us/azure/frontdoor/create-front-door-bicep?tabs=CLI)
- [Security logs and alerts using Azure services](https://learn.microsoft.com/en-us/azure/architecture/framework/security/monitor-logs-alerts)

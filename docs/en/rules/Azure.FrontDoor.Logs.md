---
severity: Important
pillar: Security
category: Security operations
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.Logs/
---

# Audit Front Door Access

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

### Configure with Azure template

To deploy a Front Door resource that passes this rule:

- Deploy a diagnostic settings sub-resource.
  - Enable logging for the `FrontdoorAccessLog` category.
  - Enable logging for the `FrontdoorWebApplicationFirewallLog` category.

For example:

```json
{
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
      "type": "Microsoft.Insights/diagnosticSettings",
      "apiVersion": "2020-05-01-preview",
      "scope": "[format('Microsoft.Cdn/profiles/{0}', parameters('frontDoorName'))]",
      "name": "service",
      "location": "[parameters('location')]",
      "properties": {
        "workspaceId": "[parameters('workSpaceId')]",
        "logs": [
          {
            "category": "FrontdoorAccessLog",
            "enabled": true
          },
          {
            "category": "FrontdoorWebApplicationFirewallLog",
            "enabled": true
          }
        ]
      },
      "dependsOn": [
        "[resourceId('Microsoft.Cdn/profiles', parameters('frontDoorName'))]"
      ]
    }
  ]
}
```

### Configure with Bicep

To deploy a Front Door resource that passes this rule:

- Deploy a diagnostic settings sub-resource.
  - Enable logging for the `FrontdoorAccessLog` category.
  - Enable logging for the `FrontdoorWebApplicationFirewallLog` category.

For example:

```bicep
targetScope = 'resourceGroup'
resource frontDoorResource 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorName
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

resource frontDoorInsightsResource 'Microsoft.Insights/diagnosticSettings@2020-05-01-preview' = {
  name: 'frontDoorInsights'
  scope: frontDoorResource
  location: 'Global'
  properties: {
    workspaceId: workspaceId
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

## LINKS

- [Monitoring metrics and logs in Azure Front Door Service](https://docs.microsoft.com/azure/frontdoor/front-door-diagnostics#diagnostic-logging)
- [Create a Front Door Standard/Premium using Bicep](https://learn.microsoft.com/azure/frontdoor/create-front-door-bicep?tabs=CLI)
- [Security logs and alerts using Azure services](https://learn.microsoft.com/eazure/architecture/framework/security/monitor-logs-alerts)

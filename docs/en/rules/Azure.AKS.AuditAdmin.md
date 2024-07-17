---
severity: Important
pillar: Cost Optimization
category: CO:07 Component costs
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AuditAdmin/
---

# kube-audit-admin

## SYNOPSIS

Use kube-audit-admin instead of kube-audit to capture administrative actions in AKS clusters.

## DESCRIPTION

Collecting resource logs for AKS clusters, particularly kube-audit logs, can be costly. Here are some recommendations to reduce data collection costs:

- Disable kube-audit logging when unnecessary: Regular kube-audit logs include all API requests, which can generate a large volume of data and increase costs.
- Enable kube-audit-admin logging: This focuses on administrative actions and excludes less critical get and list events, reducing the amount of data collected without sacrificing important security information.

## RECOMMENDATION

Consider using kube-audit-admin logging instead of kube-audit when detailed logging of every API request is not required.
This approach helps in managing log volume and associated costs while still capturing essential administrative actions.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for the `kube-audit-admin` category and disable logging for the `kube-audit` category.

For example:

```json
{
  "type": "Microsoft.Insights/diagnosticSettings",
  "apiVersion": "2021-05-01-preview",
  "scope": "[format('Microsoft.ContainerService/managedClusters/{0}', parameters('clusterName'))]",
  "name": "[parameters('name')]",
  "properties": {
    "logs": [
      {
        "category": "kube-audit-admin",
        "enabled": true,
        "retentionPolicy": {
          "days": 0,
          "enabled": false
        }
      },
      {
        "category": "kube-audit",
        "enabled": false,
        "retentionPolicy": {
          "days": 0,
          "enabled": false
        }
      }
    ],
    "workspaceId": "[parameters('workspaceId')]",
    "logAnalyticsDestinationType": "Dedicated"
  },
  "dependsOn": [
    "[resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName'))]"
  ]
}
```

### Configure with Bicep

To deploy AKS clusters that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for the `kube-audit-admin` category and disable logging for the `kube-audit` category.

For example:

```bicep
resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: name
  scope: aks
  properties: {
    logs: [
      {
        category: 'kube-audit-admin'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'kube-audit'
        enabled: false
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    workspaceId: workspaceId
    logAnalyticsDestinationType: 'Dedicated'
  }
}
```

## LINKS

- [CO:07 Component costs](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-component-costs)
- [Monitor AKS](https://learn.microsoft.com/azure/aks/monitor-aks)
- [AKS control plane/resource logs](https://learn.microsoft.com/azure/aks/monitor-aks#aks-control-planeresource-logs)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)

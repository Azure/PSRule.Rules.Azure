---
reviewed: 2024-07-23
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

Key components in a Kubernetes cluster regularly scan or check for updated Kubernetes resources against the API server.
These _get_ and _list_ operations typically occur more frequently as a Kubernetes cluster grows.

Auditing within AKS writes log events for each operation that occur against the API server.
As a result, collecting audit logs for _get_ and _list_ operations of a production AKS cluster can increase cost exponentially.

AKS provides two log categories for collecting audit logs, `kube-audit` and `kube-audit-admin`.

- `kube-audit` - Audit log data for every audit event including _get_, _list_, _create_, _update_, _delete_, _patch_, and _post_.
- `kube-audit-admin` - Is a subset of the `kube-audit` log category that excludes _get_ and _list_ audit events.

In other words, both `kube-audit` and `kube-audit-admin` contain the same data except `kube-audit-admin` does not contain _get_ and _list_ events.
Changes to the cluster configuration are captured with _create_, _update_, _delete_, _patch_, and _post_ events.

By using `kube-audit-admin`, changes to resources in AKS are audited, however events relating to reading resources and configuration are not.
This significantly reduces the number of logs and overall cost for collecting and storing AKS audit events.

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

<!-- external:avm avm/res/container-service/managed-cluster diagnosticSettings -->

## LINKS

- [CO:07 Component costs](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-component-costs)
- [Monitoring AKS data reference](https://learn.microsoft.com/azure/aks/monitor-aks-reference)
- [AKS control plane/resource logs](https://learn.microsoft.com/azure/aks/monitor-aks#aks-control-planeresource-logs)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)

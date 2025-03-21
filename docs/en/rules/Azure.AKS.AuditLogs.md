---
reviewed: 2024-07-23
severity: Important
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters,Microsoft.Insights/diagnosticSettings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AuditLogs/
---

# AKS clusters should collect security-based audit logs

## SYNOPSIS

AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads.

## DESCRIPTION

The Azure Kubernetes Service (AKS) service supports collection of security-based audit logs from clusters.
The following log categories are available:

- `kube-audit` - Audit log data for every audit event including _get_, _list_, _create_, _update_, _delete_, _patch_, and _post_.
- `kube-audit-admin` - Is a subset of the `kube-audit` log category that excludes _get_ and _list_ audit events.
- `guard` - Contains logs for Entra ID and Azure RBAC events.

In other words, both `kube-audit` and `kube-audit-admin` contain the same data except `kube-audit-admin` does not contain _get_ and _list_ events.

For most configurations, consider enabling logging for `kube-audit-admin` and `guard`.
This configuration provides good coverage and significantly reduces the number of logs and overall cost for collecting and storing AKS audit events.
Enable `kube-audit` only when required.

## RECOMMENDATION

Consider configuring diagnostic settings to capture security-based audit logs from AKS clusters.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for `kube-audit-admin` (or `kube-audit`) and `guard` log categories.

For example:

```json
{
  "type": "Microsoft.Insights/diagnosticSettings",
  "apiVersion": "2021-05-01-preview",
  "scope": "[format('Microsoft.ContainerService/managedClusters/{0}', parameters('name'))]",
  "name": "audit",
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
        "category": "guard",
        "enabled": true,
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
    "[resourceId('Microsoft.ContainerService/managedClusters', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy AKS clusters that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for `kube-audit-admin` (or `kube-audit`) and `guard` log categories.

For example:

```bicep
resource auditLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'audit'
  scope: cluster
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
        category: 'guard'
        enabled: true
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

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [Monitoring AKS data reference](https://learn.microsoft.com/azure/aks/monitor-aks-reference)
- [AKS control plane/resource logs](https://learn.microsoft.com/azure/aks/monitor-aks#aks-control-planeresource-logs)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)

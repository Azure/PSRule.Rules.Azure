---
severity: Important
pillar: Security
category: Security operations
resource: Arc
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Arc.Kubernetes.Defender/
---

# Use Microsoft Defender

## SYNOPSIS

Deploy Microsoft Defender for Containers extension for Arc-enabled Kubernetes clusters.

## DESCRIPTION

Defender for Containers relies on the Defender extension for several features.

To collect and provide data plane protections of Microsoft Defender for Containers, the extension must be deployed to the Arc connected Kubernetes cluster.
The extension will deploy some additional daemon set and deployments to the cluster.

## RECOMMENDATION

Consider deploying the Microsoft Defender for Containers extension for Arc-enabled Kubernetes clusters.

## EXAMPLES

### Configure with Azure template

To deploy Arc-enabled Kubernetes clusters that pass this rule:

- Deploy a `Microsoft.KubernetesConfiguration/extensions` sub-resource (extension resource).
- Set the `properties.extensionType` property to `microsoft.azuredefender.kubernetes`.

For example:

```json
{
  "type": "Microsoft.KubernetesConfiguration/extensions",
  "apiVersion": "2022-11-01",
  "scope": "[format('Microsoft.Kubernetes/connectedClusters/{0}', parameters('name'))]",
  "name": "microsoft.azuredefender.kubernetes",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "extensionType": "microsoft.azuredefender.kubernetes",
    "configurationSettings": {
      "logAnalyticsWorkspaceResourceID": "[parameters('logAnalyticsWorkspaceResourceID')]",
       "auditLogPath": "/var/log/kube-apiserver/audit.log"
    },
    "configurationProtectedSettings": {
      "omsagent.secret.wsid": "[parameters('wsid')]",
      "omsagent.secret.key": "[parameters('key')]"
    },
    "autoUpgradeMinorVersion": true,
    "releaseTrain": "Stable",
    "scope": {
      "cluster": {
        "releaseNamespace": "azuredefender"
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Kubernetes/connectedClusters', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy Arc-enabled Kubernetes clusters that pass this rule:

- Deploy a `Microsoft.KubernetesConfiguration/extensions` sub-resource (extension resource).
- Set the `properties.extensionType` property to `microsoft.azuredefender.kubernetes`.

For example:

```bicep
resource defenderExtension 'Microsoft.KubernetesConfiguration/extensions@2022-11-01' = {
  name: 'microsoft.azuredefender.kubernetes'
  scope: arcKubernetesCluster
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    extensionType: 'microsoft.azuredefender.kubernetes'
    configurationSettings: {
      logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceID
      auditLogPath: '/var/log/kube-apiserver/audit.log'
    }
    configurationProtectedSettings: {
      'omsagent.secret.wsid': wsid
      'omsagent.secret.key': key
    }
    autoUpgradeMinorVersion: true
    releaseTrain: 'Stable'
    scope: {
      cluster: {
        releaseNamespace: 'azuredefender'
      }
    }
  }
}
```

## LINKS

- [Security operations](https://learn.microsoft.com/azure/architecture/framework/security/security-operations)
- [Defender for Containers architecture](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-architecture)
- [Enable Microsoft Defender for Containers](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-containers-enable?pivots=defender-for-container-arc)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-arc-enabled-kubernetes-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.kubernetesconfiguration/extensions)

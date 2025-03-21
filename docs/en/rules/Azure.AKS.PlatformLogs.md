---
severity: Important
pillar: Operational Excellence
category: Monitoring
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters,Microsoft.Insights/diagnosticSettings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.PlatformLogs/
---

# AKS clusters should collect platform diagnostic logs

## SYNOPSIS

AKS clusters should collect platform diagnostic logs to monitor the state of workloads.

## DESCRIPTION

To capture platform logs from AKS clusters, the following diagnostic log/metric categories should be enabled:

- `cluster-autoscaler`
  - Understand why the AKS cluster is scaling up or down, which may not be expected. This information is also useful to correlate time intervals where something interesting may have happened in the cluster.
- `kube-apiserver`
  - Logs from the Kubernetes API server.
- `kube-controller-manager`
  - Gain deeper visibility of issues that may arise between Kubernetes and the Azure control plane. A typical example is the AKS cluster having a lack of permissions to interact with Azure.
- `kube-scheduler`
  - Logs from the Kubernetes scheduler.
- `AllMetrics`
  - Includes all platform metrics. Sends these values to Log Analytics workspace where it can be evaluated with other data using log queries.

## RECOMMENDATION

Consider configuring diagnostic settings to capture platform logs from AKS clusters.

## NOTES

Configure `AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST` to enable selective log categories. By default all log categories are selected, as shown below.

```yaml
# YAML: The default AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option
configuration:
  AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: ['cluster-autoscaler', 'kube-apiserver', 'kube-controller-manager', 'kube-scheduler', 'AllMetrics']
```

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for the `cluster-autoscaler`, `kube-apiserver`, `kube-controller-manager`, `kube-scheduler` and `AllMetrics` categories.

For example:

```json
{
    "comments": "Azure Kubernetes Cluster",
    "apiVersion": "2020-12-01",
    "dependsOn": [
        "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName'))]"
    ],
    "type": "Microsoft.ContainerService/managedClusters",
    "location": "[parameters('location')]",
    "name": "[parameters('clusterName')]",
    "identity": {
        "type": "UserAssigned",
        "userAssignedIdentities": {
            "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName'))]": {}
        }
    },
    "properties": {
        "kubernetesVersion": "[parameters('kubernetesVersion')]",
        "disableLocalAccounts": true,
        "enableRBAC": true,
        "dnsPrefix": "[parameters('dnsPrefix')]",
        "agentPoolProfiles": [
            {
                "name": "system",
                "osDiskSizeGB": 32,
                "count": 3,
                "minCount": 3,
                "maxCount": 10,
                "enableAutoScaling": true,
                "maxPods": 50,
                "vmSize": "Standard_D2s_v3",
                "osType": "Linux",
                "type": "VirtualMachineScaleSets",
                "vnetSubnetID": "[variables('clusterSubnetId')]",
                "mode": "System",
                "osDiskType": "Ephemeral",
                "scaleSetPriority": "Regular"
            }
        ],
        "aadProfile": {
            "managed": true,
            "enableAzureRBAC": true,
            "adminGroupObjectIDs": "[parameters('clusterAdmins')]",
            "tenantID": "[subscription().tenantId]"
        },
        "networkProfile": {
            "networkPlugin": "azure",
            "networkPolicy": "azure",
            "loadBalancerSku": "Standard",
            "serviceCidr": "192.168.0.0/16",
            "dnsServiceIP": "192.168.0.4",
            "dockerBridgeCidr": "172.17.0.1/16"
        },
        "autoUpgradeProfile": {
            "upgradeChannel": "stable"
        },
        "addonProfiles": {
            "azurepolicy": {
                "enabled": true,
                "config": {
                    "version": "v2"
                }
            },
            "omsagent": {
                "enabled": true,
                "config": {
                    "logAnalyticsWorkspaceResourceID": "[parameters('workspaceId')]"
                }
            },
            "kubeDashboard": {
                "enabled": false
            }
        }
    },
    "resources": [
        {
            "apiVersion": "2016-09-01",
            "type": "Microsoft.ContainerService/managedClusters/providers/diagnosticSettings",
            "name": "[concat(parameters('clusterName'), '/Microsoft.Insights/service')]",
            "properties": {
                "workspaceId": "[parameters('workspaceId')]",
                "logs": [
                    {
                        "category": "kube-apiserver",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    },
                    {
                        "category": "kube-controller-manager",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    },
                    {
                        "category": "kube-scheduler",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    },
                    {
                        "category": "cluster-autoscaler",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    }
                ],
                "metrics": [
                    {
                        "category": "AllMetrics",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    }
                ]
            }
        }
    ]
}
```

## LINKS

- [Platform Monitoring](https://learn.microsoft.com/azure/architecture/framework/devops/monitoring#platform-monitoring)
- [Monitoring AKS data reference](https://learn.microsoft.com/azure/aks/monitor-aks-reference)
- [Collect resource logs](https://learn.microsoft.com/azure/aks/monitor-aks#collect-resource-logs)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings?tabs=json)

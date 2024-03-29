---
severity: Important
pillar: Operational Excellence
category: Monitoring
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.ContainerInsights/
---

# Enable AKS Container insights

## SYNOPSIS

Enable Container insights to monitor AKS cluster workloads.

## DESCRIPTION

With Container insights, you can use performance charts and health status to monitor AKS clusters, nodes and pods.
Container insights delivers quick, visual and actionable information: from the CPU and memory pressure of your nodes to the logs of individual Kubernetes pods.

## RECOMMENDATION

Consider enabling Container insights for AKS clusters.
Monitoring containers is critical, especially when running production AKS clusters at scale with multiple applications.

## EXAMPLES

### Configure with Azure template

To enable Container insights for an AKS cluster:

- Set `properties.addonProfiles.omsAgent.enabled` to `true`.
- Set Log Analytics workspace ID with `properties.addonProfiles.omsAgent.config.logAnalyticsWorkspaceResourceID`.

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
    }
}
```

### Configure with Azure CLI

#### Enable for default Log Analytics workspace

```bash
az aks enable-addons \
  --addons monitoring \
  --name '<cluster_name>' \
  --resource-group '<cluster_resource_group>'
```

#### Enable for an existing Log Analytics workspace

```bash
az aks enable-addons \
  --addons monitoring \
  --name '<cluster_name>' \
  --resource-group '<cluster_resource_group>' \
  --workspace-resource-id '<workspace_id>'
```

## LINKS

- [Container Insights](https://learn.microsoft.com/azure/architecture/framework/devops/monitoring#container-insights)
- [Monitor your Kubernetes cluster performance with Container insights](https://learn.microsoft.com/azure/azure-monitor/containers/container-insights-analyze)
- [Container insights overview](https://learn.microsoft.com/azure/azure-monitor/containers/container-insights-overview)
- [Enable monitoring of a new Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/azure/azure-monitor/containers/container-insights-enable-new-cluster)
- [Enable monitoring of Azure Kubernetes Service (AKS) cluster already deployed](https://learn.microsoft.com/azure/azure-monitor/containers/container-insights-enable-existing-clusters)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

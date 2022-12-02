---
severity: Important
pillar: Performance Efficiency
category: Performance
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AutoScaling/
---

# Enable AKS cluster autoscaler

## SYNOPSIS

Use Autoscaling to ensure AKS clusters deployed with virtual machine scale sets are running efficiently with the right number of nodes for the workloads present.

## DESCRIPTION

In addition to perform manual scaling, AKS clusters support autoscaling.
Autoscaling reduces manual intervention required to scale a cluster to keep up with application demands.

## RECOMMENDATION

Consider enabling autoscaling for AKS clusters deployed with virtual machine scale sets.

## EXAMPLES

### Configure with Azure template

To set enable autoscaling for an AKS cluster:

- Set `properties.agentPoolProfiles[*].enableAutoScaling` to `true`.
- Set `properties.agentPoolProfiles[*].type` to `VirtualMachineScaleSets`.

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

#### Enable cluster autoscaler

```bash
az aks update \
  --name '<name>' \
  --resource-group '<resource_group>' \
  --enable-cluster-autoscaler \
  --min-count '<min_count>' \
  --max-count '<max_count>'
```

#### Enable cluster nodepool autoscaler

```bash
az aks nodepool update \
  --name '<name>' \
  --resource-group '<resource_group>' \
  --cluster-name '<cluster_name>' \
  --enable-cluster-autoscaler \
  --min-count '<min_count>' \
  --max-count '<max_count>'
```

## LINKS

- [Autoscale with Azure compute services](https://learn.microsoft.com/azure/architecture/framework/scalability/design-scale#autoscale-with-azure-compute-services)
- [Autoscaling](https://docs.microsoft.com/azure/architecture/best-practices/auto-scaling)
- [Automatically scale a cluster to meet application demands on Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/cluster-autoscaler)
- [Scaling options for applications in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/concepts-scale)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#managedclusteragentpoolprofile-object)

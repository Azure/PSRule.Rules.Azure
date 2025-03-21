---
reviewed: 2024-02-17
severity: Important
pillar: Performance Efficiency
category: PE:05 Scaling and partitioning
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters,Microsoft.ContainerService/managedClusters/agentPools
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AutoScaling/
---

# Enable AKS cluster autoscaler

## SYNOPSIS

Use autoscaling to scale clusters based on workload requirements.

## DESCRIPTION

In addition to perform manual scaling, AKS clusters support autoscaling.
Autoscaling reduces manual intervention required to scale a cluster up/ down to keep up with changing workload requirements.
Scaling is performed on a node pool, which is a group of nodes with the same configuration within a cluster.

Within AKS, the cluster autoscaler monitors pods and nodes in the cluster.
When a pod cannot be scheduled due to resource constraints,
the cluster autoscaler increases the number of nodes in the node pool.
When a node is underutilized, the cluster autoscaler removes the node from the node pool.
Scaling is performed within the range of `minCount` and `maxCount` properties set on the node pool.

In addition to performance efficiency,
autoscaling can also help reduce costs when the cluster is underutilized enough to reduce the number of nodes.

When scaling an AKS cluster manually or with auto-scale, consider the following:

- When you are using Azure CNI, ensure that there is enough IP address space in the node pool subnet.
  The node pools subnet should have enough IP address space to accommodate the `maxCount` nodes and nodes added during upgrades.
- Plan for the cost of running the cluster nodes between `minCount` and `maxCount` nodes.

## RECOMMENDATION

Consider deploying AKS clusters with virtual machine scale sets node pools and enable autoscaling.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set the `properties.agentPoolProfiles[*].enableAutoScaling` property to `true`.
- Set the `properties.agentPoolProfiles[*].type` property to `VirtualMachineScaleSets`.
- Set the `properties.agentPoolProfiles[*].minCount` and `properties.agentPoolProfiles[*].maxCount` properties.
  The cluster autoscaler will adjust the number of nodes between (inclusive of) these values.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2023-11-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "UserAssigned",
    "userAssignedIdentities": {
      "[format('{0}', resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName')))]": {}
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
        "osDiskSizeGB": 0,
        "minCount": 3,
        "maxCount": 5,
        "enableAutoScaling": true,
        "maxPods": 50,
        "vmSize": "Standard_D4s_v5",
        "type": "VirtualMachineScaleSets",
        "vnetSubnetID": "[parameters('clusterSubnetId')]",
        "mode": "System",
        "osDiskType": "Ephemeral"
      },
      {
        "name": "user",
        "osDiskSizeGB": 0,
        "minCount": 3,
        "maxCount": 20,
        "enableAutoScaling": true,
        "maxPods": 50,
        "vmSize": "Standard_D4s_v5",
        "type": "VirtualMachineScaleSets",
        "vnetSubnetID": "[parameters('clusterSubnetId')]",
        "mode": "User",
        "osDiskType": "Ephemeral"
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
      "loadBalancerSku": "standard",
      "serviceCidr": "[variables('serviceCidr')]",
      "dnsServiceIP": "[variables('dnsServiceIP')]"
    },
    "apiServerAccessProfile": {
      "authorizedIPRanges": [
        "0.0.0.0/32"
      ]
    },
    "autoUpgradeProfile": {
      "upgradeChannel": "stable"
    },
    "oidcIssuerProfile": {
      "enabled": true
    },
    "addonProfiles": {
      "azurepolicy": {
        "enabled": true
      },
      "omsagent": {
        "enabled": true,
        "config": {
          "logAnalyticsWorkspaceResourceID": "[parameters('workspaceId')]"
        }
      },
      "azureKeyvaultSecretsProvider": {
        "enabled": true,
        "config": {
          "enableSecretRotation": "true"
        }
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName'))]"
  ]
}
```

### Configure with Bicep

To deploy AKS clusters that pass this rule:

- Set the `properties.agentPoolProfiles[*].enableAutoScaling` property to `true`.
- Set the `properties.agentPoolProfiles[*].type` property to `VirtualMachineScaleSets`.
- Set the `properties.agentPoolProfiles[*].minCount` and `properties.agentPoolProfiles[*].maxCount` properties.
  The cluster autoscaler will adjust the number of nodes between (inclusive of) these values.

For example:

```bicep
resource clusterWithPools 'Microsoft.ContainerService/managedClusters@2023-11-01' = {
  location: location
  name: name
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    disableLocalAccounts: true
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'system'
        osDiskSizeGB: 0
        minCount: 3
        maxCount: 5
        enableAutoScaling: true
        maxPods: 50
        vmSize: 'Standard_D4s_v5'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: clusterSubnetId
        mode: 'System'
        osDiskType: 'Ephemeral'
      }
      {
        name: 'user'
        osDiskSizeGB: 0
        minCount: 3
        maxCount: 20
        enableAutoScaling: true
        maxPods: 50
        vmSize: 'Standard_D4s_v5'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: clusterSubnetId
        mode: 'User'
        osDiskType: 'Ephemeral'
      }
    ]
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      adminGroupObjectIDs: clusterAdmins
      tenantID: subscription().tenantId
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
    }
    apiServerAccessProfile: {
      authorizedIPRanges: [
        '0.0.0.0/32'
      ]
    }
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    addonProfiles: {
      azurepolicy: {
        enabled: true
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
        }
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

- [PE:05 Scaling and partitioning](https://learn.microsoft.com/azure/well-architected/performance-efficiency/scale-partition)
- [Autoscaling](https://learn.microsoft.com/azure/architecture/best-practices/auto-scaling)
- [Use the cluster autoscaler in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/cluster-autoscaler)
- [Scaling options for applications in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/concepts-scale)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

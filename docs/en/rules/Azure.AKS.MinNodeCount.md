---
reviewed: 2024-02-21
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.MinNodeCount/
ms-content-id: 320afea5-5c19-45ad-b9a5-c1a63ae6e114
---

# Minimum number of system nodes in an AKS cluster

## SYNOPSIS

AKS clusters should have minimum number of system nodes for failover and updates.

## DESCRIPTION

Azure Kubernetes (AKS) clusters support multiple nodes and node pools.
Each node is a virtual machine (VM) that runs Kubernetes components and a container runtime.
A node pool is a grouping of nodes that run the same configuration.
Application or system pods can be scheduled to run across multiple nodes to ensure resiliency and high availability.
AKS supports configuring one or more system node pools, and zero or more user node pools.

System node pools are intended for pods that perform important management and infrastructure functions for cluster operation.
This includes CoreDNS, konnectivity, and Azure Policy to name a few.
The number of pods that are scheduled to run on system node pools varies based on the configuration of your cluster.

User node pools are intended for application pods.
In general, schedule application workloads to run on user node pools to avoid disrupting the operation of system pods.

A minimum number of nodes in each node pool should be maintained to ensure resiliency during node failures or disruptions.
Also consider how your nodes are distributed across availability zones when deploying to a supported region.
Understanding that adding new nodes to a node pool can take time.

For example, in a three-node node pool:

- If one node fails ~33% capacity is lost until a new node is created to replace the failed node.
- The pods running on the failed node may be rescheduled to run on the remaining two nodes if there is enough capacity.
  However, there is a number of factors that affect which pods will be scheduled to run on the two remaining nodes.

For example, in a 2x two-node node pool:

- If 2x two node pools are deployed both with availability zones `1`, `2`.
  AKS will automatically spread the nodes across the two availability zones as it scales out.
- If availability zone `1` fails, 50% capacity on the remaining nodes in availability zone `2` will continue to run pods.
- Pods running on the failed nodes in availability zone `1` will be rescheduled to run pending enough capacity.

## RECOMMENDATION

Consider configuring AKS clusters with at least three (3) agent nodes in system node pools.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

To deploy AKS clusters that pass this rule:

- For a single system mode node pool `properties.agentPoolProfiles`:
  - Set the `minCount` property to at least `3` for node pools with auto-scale. _OR_
  - Set the `count` property to at least `3` for node pools without auto-scale. _OR_
- Deploy an additional system mode node pool so the total number of nodes is at least `3` across all pools.
  For example, two node pools with `minCount` set to `2` totalling _4_ nodes.

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

- For a single system mode node pool `properties.agentPoolProfiles`:
  - Set the `minCount` property to at least `3` for node pools with auto-scale. _OR_
  - Set the `count` property to at least `3` for node pools without auto-scale. _OR_
- Deploy an additional system mode node pool so the total number of nodes is at least `3` across all pools.
  For example, two node pools with `minCount` set to `2` totalling _4_ nodes.

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

## NOTES

### Rule configuration

<!-- module:config rule AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES -->

This rule fails by default if you have less than three (3) nodes in the cluster across all system node pools.
To change the default, set the `AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES` configuration option.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Azure Well-Architected Framework review - Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service)
- [Manage node pools for a cluster in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/manage-node-pools)
- [Manage system node pools in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/use-system-pools)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

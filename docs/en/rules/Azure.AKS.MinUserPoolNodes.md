---
reviewed: 2024-02-21
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.MinUserPoolNodes/
---

# Minimum number of nodes in a user node pool

## SYNOPSIS

User node pools in an AKS cluster should have a minimum number of nodes for failover and updates.

## DESCRIPTION

Azure Kubernetes (AKS) clusters support multiple nodes and node pools.
Each node is a virtual machine (VM) that runs Kubernetes components and a container runtime.
A node pool is a grouping of nodes that run the same configuration.
Application or system pods can be scheduled to run across multiple nodes to ensure resiliency and high availability.
AKS supports configuring one or more system node pools, and zero or more user node pools.

User node pools are intended for application pods.

A minimum number of nodes in each node pool should be maintained to ensure resiliency during node failures or disruptions.
Resiliency in application pods is also dependent on the number of replicas and the distribution of pods across nodes.
Application pods may be configured to use specific node pools based on access features such as GPU or access to storage.

Also consider how your nodes are distributed across availability zones when deploying to a supported region.
Understanding that adding new nodes to a node pool can take time.

## RECOMMENDATION

Consider configuring AKS clusters with at least three (3) agent nodes in each user node pools.

## EXAMPLES

### Configure with Azure template

- For each user node pool `properties.agentPoolProfiles`:
  - Set the `minCount` property to at least `3` for node pools with auto-scale. _OR_
  - Set the `count` property to at least `3` for node pools without auto-scale.

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

- For each user node pool `properties.agentPoolProfiles`:
  - Set the `minCount` property to at least `3` for node pools with auto-scale. _OR_
  - Set the `count` property to at least `3` for node pools without auto-scale.

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

Node pools that are configured for spot instances are excluded from this rule.
Spot instances can be used for burst capacity but do not provide a guarantee of availability.

### Rule configuration

<!-- module:config rule AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES -->

This rule fails by default if you have less than three (3) nodes in each user node pool.
To change the default, set the `AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES` configuration option.

<!-- module:config rule AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES -->

To exclude a specific user node pool by name from this rule,
set the `AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES` configuration option.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Azure Well-Architected Framework review - Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service)
- [Manage node pools for a cluster in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/manage-node-pools)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

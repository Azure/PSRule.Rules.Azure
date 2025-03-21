---
severity: Important
pillar: Performance Efficiency
category: Application scalability
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters,Microsoft.ContainerService/managedClusters/agentPools
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.PoolScaleSet/
---

# AKS clusters use VM scale sets

## SYNOPSIS

Deploy AKS clusters with nodes pools based on VM scale sets.

## DESCRIPTION

When deploying AKS clusters, Azure node pool VMs can be deployed using Availability Sets or VM Scale Sets.
New AKS clusters default to VM scale set node pools.

Deploying AKS clusters with scale set node pools is required for some cluster features such as multiple node pools and cluster autoscaler.

## RECOMMENDATION

Multiple node pools and the cluster autoscaler can be used to improve the scalability and performance of a cluster while minimizing cost.

Using VM scale sets is a deployment time configuration.
Consider redeploying the AKS cluster with VM Scale Sets instead of Availability Sets.

## EXAMPLES

### Configure with Azure template

To deploy clusters that pass this rule:

- Set the `properties.agentPoolProfiles[].type` property to `VirtualMachineScaleSets` for each node pool.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2023-04-01",
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
    "identity"
  ]
}
```

### Configure with Bicep

To deploy clusters that pass this rule:

- Set the `properties.agentPoolProfiles[].type` property to `VirtualMachineScaleSets` for each node pool.

For example:

```bicep
resource clusterWithPools 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
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

## LINKS

- [Plan for growth](https://learn.microsoft.com/azure/well-architected/scalability/design-scale#plan-for-growth)
- [Create and manage multiple node pools for a cluster in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/use-multiple-node-pools)
- [Scaling options for applications in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/concepts-scale#cluster-autoscaler)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

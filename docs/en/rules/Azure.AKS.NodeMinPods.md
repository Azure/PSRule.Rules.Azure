---
severity: Important
pillar: Performance Efficiency
category: Application scalability
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.NodeMinPods/
---

# Nodes use a minimum number of pods

## SYNOPSIS

Azure Kubernetes Cluster (AKS) nodes should use a minimum number of pods.

## DESCRIPTION

Node pools within a Azure Kubernetes Cluster (AKS) support between 30 and 250 pods per node.
The maximum number of pods for nodes within a node pool is set at deployment time.

When deploying AKS clusters with _kubernet_ networking the default maximum number of pods is 110.
For Azure CNI AKS clusters, the default maximum number of pods is 30.

In many environments, deploying DaemonSets for monitoring and management tools can exhaust the CNI default.

## RECOMMENDATION

Consider deploying node pools with a minimum number of pods per node.

## EXAMPLES

### Configure with Azure template

To deploy clusters that pass this rule:

- Set the `properties.agentPoolProfiles[].maxPods` property to at least `50` by default.

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

- Set the `properties.agentPoolProfiles[].maxPods` property to at least `50` by default.

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

## NOTES

By default, this rule fails when node pools have `maxPods` set to less than 50.

To configure this rule:

- Override the `Azure_AKSNodeMinimumMaxPods` configuration value with the minimum maxPods.

## LINKS

- [Plan for growth](https://learn.microsoft.com/azure/well-architected/scalability/design-scale#plan-for-growth)
- [Plan IP addressing for your cluster](https://learn.microsoft.com/azure/aks/configure-azure-cni#plan-ip-addressing-for-your-cluster)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

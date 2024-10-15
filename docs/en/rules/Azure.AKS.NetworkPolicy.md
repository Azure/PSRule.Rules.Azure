---
reviewed: 2024-10-14
severity: Important
pillar: Security
category: SE:04 Segmentation
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.NetworkPolicy/
---

# AKS network policies are not configured

## SYNOPSIS

AKS clusters without inter-pod network restrictions may be permit unauthorized lateral movement.

## DESCRIPTION

AKS clusters provides a platform to host containerized workloads.
The running of these applications or services is orchestrated by Kubernetes.
Workloads may elastic scale or change network addressing.

By default, all pods in an AKS cluster can send and receive traffic without limitations.
Network Policy defines access policies for limiting network communication of pods.
Using Network Policies allows network controls to be applied with the context of the workload.

For improved security, define network policy rules to control the flow of traffic.
For example, only permit backend components to receive traffic from frontend components.

When network communication is unrestricted, your applications or infrastructure may be exposed to lateral movement.
Lateral movement is technique used to bypass controls, increase impact, and escalate privileges.

To use Network Policy it must be enabled at cluster deployment time.
AKS supports two implementations of network policies, Azure Network Policies and Calico Network Policies.
Azure Network Policies are supported by Azure support and engineering teams.

## RECOMMENDATION

Consider deploying AKS clusters with network policy enabled to extend network segmentation into clusters.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.networkProfile.networkPolicy` to `azure` or `calico`.

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

- Set `properties.networkProfile.networkPolicy` to `azure` or `calico`.

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

Network Policy can only be set during initial cluster creation.
Existing AKS clusters must be redeployed to enable Network Policy.

## LINKS

- [SE:04 Segmentation](https://learn.microsoft.com/azure/well-architected/security/segmentation)
- [NS-1: Establish network segmentation boundaries](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-kubernetes-service-aks-security-baseline#ns-1-establish-network-segmentation-boundaries)
- [Secure traffic between pods using network policies in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/use-network-policies)
- [Best practices for network connectivity and security in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/operator-best-practices-network#control-traffic-flow-with-network-policies)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Azure Well-Architected Framework review - Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

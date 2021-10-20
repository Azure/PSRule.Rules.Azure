---
severity: Important
pillar: Security
category: Network segmentation
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.NetworkPolicy/
---

# AKS clusters use Network Policies

## SYNOPSIS

Deploy AKS clusters with Network Policies enabled.

## DESCRIPTION

AKS clusters provides a platform to host containerized workloads.
The running of these applications or services is orchestrated by Kubernetes.
Workloads may elasticly scale or change network addressing.

By default, all pods in an AKS cluster can send and receive traffic without limitations.
Network Policy defines access policies for limiting network communication of pods.
Using Network Policies allows network controls to be applied with the context of the workload.

For improved security, define network policy rules to control the flow of traffic.
For example, only permit backend components to receive traffic from frontend components.

To use Network Policy it must be enabled at cluster deployment time.
AKS supports two implementations of network policies, Azure Network Policies and Calico Network Policies.
Azure Network Policies are supported by Azure support and engineering teams.

## RECOMMENDATION

Consider deploying AKS clusters with network policy enabled to extend network segmentation into clusters.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `Properties.networkProfile.networkPolicy` to `azure` or `calico`.

For example:

```json
{
    "type": "Microsoft.ContainerService/managedClusters",
    "apiVersion": "2021-07-01",
    "name": "[parameters('clusterName')]",
    "location": "[parameters('location')]",
    "identity": {
        "type": "UserAssigned",
        "userAssignedIdentities": {
            "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName'))]": {}
        }
    },
    "properties": {
        "kubernetesVersion": "[parameters('kubernetesVersion')]",
        "enableRBAC": true,
        "dnsPrefix": "[parameters('dnsPrefix')]",
        "agentPoolProfiles": "[variables('allPools')]",
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
            "dnsServiceIP": "[variables('dnsServiceIP')]",
            "dockerBridgeCidr": "[variables('dockerBridgeCidr')]"
        },
        "autoUpgradeProfile": {
            "upgradeChannel": "[parameters('upgradeChannel')]"
        },
        "addonProfiles": {
            "httpApplicationRouting": {
                "enabled": false
            },
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
            },
            "azureKeyvaultSecretsProvider": {
                "enabled": true,
                "config": {
                    "enableSecretRotation": "[string(parameters('useSecretRotation'))]"
                }
            },
            "openServiceMesh": {
                "enabled": "[parameters('useOpenServiceMesh')]"
            }
        }
    },
    "tags": "[parameters('tags')]",
    "dependsOn": [
        "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName'))]"
    ]
}
```

### Configure with Bicep

To deploy AKS clusters that pass this rule:

- Set `Properties.networkProfile.networkPolicy` to `azure` or `calico`.

For example:

```bicep
resource cluster 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  location: location
  name: clusterName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: allPools
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
      dockerBridgeCidr: dockerBridgeCidr
    }
    autoUpgradeProfile: {
      upgradeChannel: upgradeChannel
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: false
      }
      azurepolicy: {
        enabled: true
        config: {
          version: 'v2'
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
      }
      kubeDashboard: {
        enabled: false
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: string(useSecretRotation)
        }
      }
      openServiceMesh: {
        enabled: useOpenServiceMesh
      }
    }
  }
  tags: tags
}
```

## NOTES

Network Policy is a deployment time configuration.
AKS clusters must be redeployed to enable Network Policy.

## LINKS

- [Implement network segmentation patterns on Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-network-segmentation)
- [Secure traffic between pods using network policies in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/use-network-policies)
- [Best practices for network connectivity and security in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/operator-best-practices-network#control-traffic-flow-with-network-policies)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

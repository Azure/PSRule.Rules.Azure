---
reviewed: 2024-06-16
severity: Important
pillar: Security
category: SE:01 Security Baseline
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.NodeAutoUpgrade/
---

# Azure AKS Node Auto-Upgrade Rule

## SYNOPSIS

Deploy AKS Clusters with Node Auto-Upgrade enabled

## DESCRIPTION

AKS provides multiple auto-upgrade channels dedicated to timely node-level OS security updates.
This channel is different from cluster-level Kubernetes version upgrades and supersedes it.
Node-level OS security updates are released at a faster rate than Kubernetes patch or minor version updates.

The node OS auto-upgrade channel grants you flexibility and enables a customized strategy for node-level OS security updates.
Then, you can choose a separate plan for cluster-level Kubernetes version auto-upgrades.
It's best to use both cluster-level auto-upgrades and the node OS auto-upgrade channel together.
When making changes to node OS auto-upgrade channels, allow up to 24 hours for the changes to take effect.

Two channels are available for kubernetes node auto-upgrade are SecurityPatch, NodeImage.
For details on the differences between the two channels, see the references below.
Once you change from one channel to another channel, a re-image is triggered leading to rolling nodes.

Node OS image auto-upgrade won't affect the cluster's Kubernetes version.

## RECOMMENDATION

AKS clusters should be configured to utilize the SecurityPatch,NodeImage upgrade channels to ensure timely security updates.
This will help maintain operational resilience by addressing known security issues and improving overall cluster performance.

This practice helps maintain the security and reliability of your AKS clusters aligning with Well Architected Framework principles.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.autoUpgradeProfile.nodeOSupgradeChannel` to `SecurityPatch` or `NodeImage`.

For example:

```json
{
    "type": "Microsoft.ContainerService/managedClusters",
    "apiVersion": "2023-07-01",
    "name": "[parameters('clusterName')]",
    "location": "[parameters('location')]",
    "identity": {
        "type": "UserAssigned",
        "userAssignedIdentities": {
            "[format('{0}', resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName')))]": {}
        }
    },
    "properties": {
        "kubernetesVersion": "1.30.6",
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
            "nodeOSUpgradeChannel": "SecurityPatch"
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
                    "enableSecretRotation": "true"
                }
            }
        },
        "podIdentityProfile": {
            "enabled": true
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

- Set `properties.autoUpgradeProfile.nodeOSupgradeChannel` to `SecurityPatch` or `NodeImage`.

For example:

```bicep
resource cluster 'Microsoft.ContainerService/managedClusters@2023-07-01' = {
  location: location
  name: clusterName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: '1.30.6'
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
      nodeOSupgradeChannel: 'SecurityPatch'
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
          enableSecretRotation: 'true'
        }
      }
    }
    podIdentityProfile: {
      enabled: true
    }
  }
  tags: tags
}
```

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --node-os-upgrade-channel 'securitypatch' . _OR_
```

```bash
az aks update -n '<name>' -g '<resource_group>' --node-os-upgrade-channel 'SecurityPatch'. _OR_ 
```

```bash
az aks update -n '<name>' -g '<resource_group>' --node-os-upgrade-channel 'NodeImage'.  
```

## NOTES

AKS releases weekly rounds of fixes and feature and component updates that affect all clusters and customers.
It's important for you to know when a particular AKS release is hitting your region.

AKS release tracker provides  specific component updates present in an AKS version release real time by versions and regions.
It also helps you to identify such fixes shipped to a core add-on, and node image updates for Azure Linux, Ubuntu, and Windows.

## LINKS

- [SE:01-Security Baseline](https://learn.microsoft.com/azure/well-architected/security/establish-baseline)
- [AutoUpgrade NodeImages](https://learn.microsoft.com/azure/aks/auto-upgrade-node-os-image?tabs=azure-cli)
- [NodeImage Upgrade](https://learn.microsoft.com/azure/aks/node-image-upgrade)
- [Process Node Updates with Kured](https://learn.microsoft.com/azure/aks/node-updates-kured)
- [NodeOSUpgrade with GithubActions](https://learn.microsoft.com/azure/aks/node-upgrade-github-actions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

---
reviewed: 2025-03-27
severity: Important
pillar: Security
category: SE:01 Security Baseline
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.NodeAutoUpgrade/
---

# Kubernetes Cluster nodes are not automatically patched

## SYNOPSIS

Operating system (OS) security updates should be applied to AKS nodes and rebooted as required to address security vulnerabilities.

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

Consider setting a channel for node OS upgrades to automatically apply OS security updates and reboot each node when required.
The upgrade of each node uses safe deployment practices to minimize downtime and impact to workloads.

## EXAMPLES

### Configure with Bicep

To deploy AKS clusters that pass this rule:

- Set `properties.autoUpgradeProfile.nodeOSupgradeChannel` to `SecurityPatch` or `NodeImage`.

For example:

```bicep
resource cluster 'Microsoft.ContainerService/managedClusters@2024-10-01' = {
  location: location
  name: clusterName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: '1.32.7'
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

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.autoUpgradeProfile.nodeOSupgradeChannel` to `SecurityPatch` or `NodeImage`.

For example:

```json
{
    "type": "Microsoft.ContainerService/managedClusters",
    "apiVersion": "2024-10-01",
    "name": "[parameters('clusterName')]",
    "location": "[parameters('location')]",
    "identity": {
        "type": "UserAssigned",
        "userAssignedIdentities": {
            "[format('{0}', resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName')))]": {}
        }
    },
    "properties": {
        "kubernetesVersion": "1.32.7",
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

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Kubernetes Service Clusters should enable node os auto-upgrade](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Kubernetes/AKS_Autoupgrade_NodeOS_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/04408ca5-aa10-42ce-8536-98955cdddd4c`.
- [Configure Node OS Auto upgrade on Azure Kubernetes Cluster](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Kubernetes/AKS_Autoupgrade_NodeOS_DINE.json)
  `/providers/Microsoft.Authorization/policyDefinitions/40f1aee2-4db4-4b74-acb1-c6972e24cca8`.

## NOTES

AKS releases weekly rounds of fixes and feature and component updates that affect all clusters and customers.
It's important for you to know when a particular AKS release is hitting your region.

AKS release tracker provides  specific component updates present in an AKS version release real time by versions and regions.
It also helps you to identify such fixes shipped to a core add-on, and node image updates for Azure Linux, Ubuntu, and Windows.

## LINKS

- [SE:01-Security Baseline](https://learn.microsoft.com/azure/well-architected/security/establish-baseline)
- [Automatically upgrade AKS cluster node OS images](https://learn.microsoft.com/azure/aks/auto-upgrade-node-os-image?tabs=azure-cli)
- [Upgrade Azure Kubernetes Service (AKS) node images](https://learn.microsoft.com/azure/aks/node-image-upgrade)
- [Apply security and kernel updates to Linux nodes in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/node-updates-kured)
- [Apply automatic security upgrades to Azure Kubernetes Service (AKS) nodes using GitHub Actions](https://learn.microsoft.com/azure/aks/node-upgrade-github-actions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

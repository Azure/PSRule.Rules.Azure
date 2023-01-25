---
reviewed: 2021/12/10
severity: Important
pillar: Operational Excellence
category: Automation
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AutoUpgrade/
---

# Set AKS auto-upgrade channel

## SYNOPSIS

Configure AKS to automatically upgrade to newer supported AKS versions as they are made available.

## DESCRIPTION

In additional to performing manual upgrades, AKS supports auto-upgrades.
Auto-upgrades reduces manual intervention required to maintain an AKS cluster.

To configure auto-upgrades select a release channel instead of the default `none`.
The following release channels are available:

- `none` - Disables auto-upgrades.
The default setting.
- `patch` - Automatically upgrade to the latest supported patch version of the current minor version.
- `stable` - Automatically upgrade to the latest supported patch release of the recommended minor version.
This is N-1 of the current AKS non-preview minor version.
- `rapid` - Automatically upgrade to the latest supported patch of the latest support minor version.
- `node-image` - Automatically upgrade to the latest node image version.
Normally upgraded weekly.

## RECOMMENDATION

Consider enabling auto-upgrades for AKS clusters by setting an auto-upgrade channel.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.autoUpgradeProfile.upgradeChannel` to an upgrade channel such as `stable`.

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
            "[format('{0}', resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName')))]": {}
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
            "upgradeChannel": "stable"
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

- Set `properties.autoUpgradeProfile.upgradeChannel` to an upgrade channel such as `stable`.

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
      upgradeChannel: 'stable'
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
  }
  tags: tags
}
```

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --auto-upgrade-channel 'stable'
```

## LINKS

- [Automation overview](https://learn.microsoft.com/azure/architecture/framework/devops/automation-overview)
- [Supported Kubernetes versions in Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/supported-kubernetes-versions)
- [Support policies for Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/support-policies)
- [Set auto-upgrade channel](https://docs.microsoft.com/azure/aks/upgrade-cluster#set-auto-upgrade-channel)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#ManagedClusterAutoUpgradeProfile)

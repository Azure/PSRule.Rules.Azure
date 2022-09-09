---
severity: Important
pillar: Reliability
category: Requirements
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.Version/
ms-content-id: b0bd4e66-af2f-4d0a-82ae-e4738418bb7e
---

# Upgrade Kubernetes version

## SYNOPSIS

AKS control plane and nodes pools should use a current stable release.

## DESCRIPTION

The AKS support policy for Kubernetes is include N-2 stable minor releases.
Additionally two patch releases for each minor version are supported.

## RECOMMENDATION

Consider upgrading AKS control plane and nodes pools to the latest stable version of Kubernetes.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `Properties.kubernetesVersion` to a newer stable version.

For example:

```json
{
    "type": "Microsoft.ContainerService/managedClusters",
    "apiVersion": "2021-10-01",
    "name": "[parameters('clusterName')]",
    "location": "[parameters('location')]",
    "identity": {
        "type": "UserAssigned",
        "userAssignedIdentities": {
            "[format('{0}', resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName')))]": {}
        }
    },
    "properties": {
        "kubernetesVersion": "1.23.8",
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

- Set `Properties.kubernetesVersion` to a newer stable version.

For example:

```bicep
resource cluster 'Microsoft.ContainerService/managedClusters@2021-10-01' = {
  location: location
  name: clusterName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: '1.23.8'
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
    podIdentityProfile: {
      enabled: true
    }
  }
  tags: tags
}
```

### Configure with Azure CLI

```bash
az aks upgrade -n '<name>' -g '<resource_group>' --kubernetes-version '1.23.8'
```

### Configure with Azure PowerShell

```powershell
Set-AzAksCluster -Name '<name>' -ResourceGroupName '<resource_group>' -KubernetesVersion '1.23.8'
```

## NOTES

A list of available Kubernetes versions can be found using the `az aks get-versions -o table --location <location>` CLI command.
To configure this rule:

- Override the `AZURE_AKS_CLUSTER_MINIMUM_VERSION` configuration value with the minimum Kubernetes version.

## LINKS

- [Target and non-functional requirements](https://docs.microsoft.com/azure/architecture/framework/resiliency/design-requirements#meet-application-platform-requirements)
- [Supported Kubernetes versions in Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/supported-kubernetes-versions)
- [Support policies for Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/support-policies)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

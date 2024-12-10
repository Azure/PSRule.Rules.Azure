---
reviewed: 2024-03-25
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.Version/
ms-content-id: b0bd4e66-af2f-4d0a-82ae-e4738418bb7e
---

# Upgrade Kubernetes version

## SYNOPSIS

AKS control plane and nodes pools should use a current stable release.

## DESCRIPTION

The AKS Kubernetes support policy provides support for the latest generally available (GA) three minor versions (N-2).
This version support policy is based on the Kubernetes community support policy, who maintain the Kubernetes project.
As the Kubernetes releases new minor versions, the old minor versions are deprecated and eventually removed from support.

When your cluster or cluster nodes are running a version that is no longer supported, you may:

- Encounter issues that may adversely affect the reliability of your cluster and cause down time.
- Have bugs or security vulnerabilities that have already been mitigated by the Kubernetes community.
- Introduce additional risk to your cluster and applications when you upgrade to a supported version.

Additionally, AKS provides _Platform Support_ for subset of components following an N-3.

AKS supports a feature called cluster auto-upgrade, which can be used to reduce operational overhead of upgrading your cluster.
This feature allows you to configure your cluster to automatically upgrade to the latest supported minor version of Kubernetes.
When you enable cluster auto-upgrade, the control plane and node pools are upgraded to the latest supported minor version.
Two channels are available for cluster auto-upgrade that maintain Kubernetes minor versions `stable` and `rapid`.
For details on the differences between the two channels, see the references below.

You are able to define a planned maintenance window to schedule and control upgrades to your cluster.
Use the Planned Maintenance window to schedule upgrades to your cluster during times of low business impact.
Alternatively, consider using blue / green clusters.

## RECOMMENDATION

Consider upgrading AKS control plane and nodes pools to the latest stable version of Kubernetes.
Also consider enabling cluster auto-upgrade within a maintenance window to minimize operational overhead of cluster upgrades.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.autoUpgradeProfile.upgradeChannel` to `rapid` or `stable`. _OR_
- Set `properties.kubernetesVersion` to a newer stable version.

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

- Set `properties.autoUpgradeProfile.upgradeChannel` to `rapid` or `stable`. _OR_
- Set `properties.kubernetesVersion` to a newer stable version.

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

<!-- external:avm avm/res/container-service/managed-cluster kubernetesVersion -->

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --auto-upgrade-channel 'stable'
```

```bash
az aks upgrade -n '<name>' -g '<resource_group>' --kubernetes-version '1.30.6'
```

### Configure with Azure PowerShell

```powershell
Set-AzAksCluster -Name '<name>' -ResourceGroupName '<resource_group>' -KubernetesVersion '1.30.6'
```

## NOTES

A list of available Kubernetes versions can be found using the `az aks get-versions -o table --location <location>` CLI command.

If you must maintain AKS clusters for longer then the community support period, consider switching to Long Term Support (LTS).
AKS LTS provides support for a specific Kubernetes version for a longer period of time.
The first LTS release is 1.27.

### Rule configuration

<!-- module:config rule AZURE_AKS_CLUSTER_MINIMUM_VERSION -->

To configure this rule override the `AZURE_AKS_CLUSTER_MINIMUM_VERSION` configuration value with the minimum Kubernetes version.

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Automatically upgrade an Azure Kubernetes Service cluster](https://learn.microsoft.com/azure/aks/auto-upgrade-cluster)
- [Supported Kubernetes versions in Azure Kubernetes Service](https://learn.microsoft.com/azure/aks/supported-kubernetes-versions#kubernetes-version-support-policy)
- [Support policies for Azure Kubernetes Service](https://learn.microsoft.com/azure/aks/support-policies)
- [Platform support policy](https://learn.microsoft.com/azure/aks/supported-kubernetes-versions#platform-support-policy)
- [Blue-green deployment of AKS clusters](https://learn.microsoft.com/azure/architecture/guide/aks/blue-green-deployment-for-aks)
- [Long Term Support (LTS)](https://learn.microsoft.com/azure/aks/supported-kubernetes-version#long-term-support-lts)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

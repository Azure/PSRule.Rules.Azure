---
severity: Important
pillar: Security
category: Authentication
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.PodIdentity/
---

# Use managed identities for AKS pod authentication

## SYNOPSIS

Configure AKS clusters to use AAD pod identities to access Azure resources securely.

## DESCRIPTION

AAD pod identities allows AKS clusters to assign a user identity to a pod in Kubernetes.

Administrators create identities and bindings as Kubernetes primitives that allow pods to access
Azure resources that rely on Azure AD as an identity provider.

## RECOMMENDATION

Consider enabling AAD pod identities on AKS clusters.

It is only recommended to use AAD pod identities with AKS clusters that use Azure CNI.

## EXAMPLES

### Configure with Azure CLI

Register `EnablePodIdentityPreview` feature:

```bash
az feature register --name EnablePodIdentityPreview --namespace Microsoft.ContainerService
```

Install the `aks-preview` Azure CLI:

```bash
# Install the aks-preview extension
az extension add --name aks-preview

# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview
```

Create AKS cluster with AAD Pod identity enabled:

```bash
az aks create -g '<resource_group>' -n '<cluster_name>' --enable-pod-identity --network-plugin azure
```

Update an existing AKS cluster with AAD pod identity enabled:

```bash
az aks update -g '<resource_group>' -n '<cluster_name>' --enable-pod-identity
```

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `Properties.networkProfile.networkPlugin` to `azure`.
- Set `Properties.podIdentityProfile.enabled` to `true`.

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

- Set `Properties.networkProfile.networkPlugin` to `azure`.
- Set `Properties.podIdentityProfile.enabled` to `true`.

For example:

```bicep
// Cluster
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
    podIdentityProfile: {
      enabled: true
    }
  }
  tags: tags
}
```

## LINKS

- [Use identity-based authentication](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-identity-based-authentication)
- [Use Azure Active Directory pod-managed identities in Azure Kubernetes Service (Preview)](https://docs.microsoft.com/azure/aks/use-azure-ad-pod-identity)
- [Use managed identities in Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/use-managed-identity)
- [What are managed identities for Azure resources?](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
- [AAD Pod Identity](https://github.com/Azure/aad-pod-identity)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

---
reviewed: 2021-12-10
severity: Important
pillar: Security
category: Key and secret management
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.SecretStoreRotation/
---

# AKS clusters refresh secrets from Key Vault

## SYNOPSIS

Enable autorotation of Secrets Store CSI Driver secrets for AKS clusters.

## DESCRIPTION

AKS clusters may need to store and retrieve secrets, keys, and certificates.
The Secrets Store CSI Driver provides cluster support to integrate with Key Vault.
When enabled and configured secrets, keys, and certificates can be securely accessed from a pod.

When secrets are updated in Key Vault, pods may need to be restarted to pick up the new secrets.
Enabling autorotation with the Secrets Store CSI Driver, automatically refreshed pods with new secrets.
It does this by periodically polling for updates to the secrets in Key Vault.
The default interval is every 2 minutes.

The Secrets Store CSI Driver does not automatically change secrets in Key Vault.
Updating the secrets in Key Vault must be done by an external process, such as an Azure Function.

## RECOMMENDATION

Consider enabling autorotation of Secrets Store CSI Driver secrets for AKS clusters.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `Properties.addonProfiles.azureKeyvaultSecretsProvider.config.enableSecretRotation` to `true`.

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

- Set `Properties.addonProfiles.azureKeyvaultSecretsProvider.config.enableSecretRotation` to `true`.

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
az aks update --enable-secret-rotation -n '<name>' -g '<resource_group>'
```

## LINKS

- [Key and secret management considerations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-keys#operational-considerations)
- [Operational considerations](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-keys#operational-considerations)
- [Use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster](https://learn.microsoft.com/azure/aks/csi-secrets-store-driver)
- [Automate the rotation of a secret for resources that use one set of authentication credentials](https://learn.microsoft.com/azure/key-vault/secrets/tutorial-rotation)
- [Automate the rotation of a secret for resources that have two sets of authentication credentials](https://learn.microsoft.com/azure/key-vault/secrets/tutorial-rotation-dual)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#ManagedClusterAutoUpgradeProfile)

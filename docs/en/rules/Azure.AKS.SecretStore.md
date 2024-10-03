---
reviewed: 2021-12-10
severity: Important
pillar: Security
category: Key and secret management
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.SecretStore/
---

# AKS clusters use Key Vault to store secrets

## SYNOPSIS

Deploy AKS clusters with Secrets Store CSI Driver and store Secrets in Key Vault.

## DESCRIPTION

AKS clusters may need to store and retrieve secrets, keys, and certificates.
The Secrets Store CSI Driver provides cluster support to integrate with Key Vault.
When enabled and configured secrets, keys, and certificates can be securely accessed from a pod.

The Secrets Store CSI Driver can automatically refresh secrets and keys periodically from Key Vault.
To enable this feature, enable Secrets Store CSI Driver autorotation.

Avoid storing secrets to access Azure resources.
Use a Managed Identity when possible instead of cryptographic keys or a regular service principal.

## RECOMMENDATION

Consider deploying AKS clusters with the Secrets Store CSI Driver and store Secrets in Key Vault.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `Properties.addonProfiles.azureKeyvaultSecretsProvider.enabled` to `true`.

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

- Set `Properties.addonProfiles.azureKeyvaultSecretsProvider.enabled` to `true`.

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

<!-- external:avm avm/res/container-service/managed-cluster enableKeyvaultSecretsProvider -->

### Configure with Azure CLI

```bash
az aks enable-addons --addons azure-keyvault-secrets-provider -n '<name>' -g '<resource_group>'
```

## LINKS

- [Key and secret management considerations in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-keys#operational-considerations)
- [Operational considerations](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-keys#operational-considerations)
- [Use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster](https://learn.microsoft.com/azure/aks/csi-secrets-store-driver)
- [Automate the rotation of a secret for resources that use one set of authentication credentials](https://learn.microsoft.com/azure/key-vault/secrets/tutorial-rotation)
- [Automate the rotation of a secret for resources that have two sets of authentication credentials](https://learn.microsoft.com/azure/key-vault/secrets/tutorial-rotation-dual)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#ManagedClusterAutoUpgradeProfile)

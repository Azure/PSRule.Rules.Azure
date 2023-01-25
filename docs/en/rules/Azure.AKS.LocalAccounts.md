---
severity: Important
pillar: Security
category: Identity and access management
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.LocalAccounts/
---

# Disable AKS local accounts

## SYNOPSIS

Enforce named user accounts with RBAC assigned permissions.

## DESCRIPTION

AKS clusters support Role-based Access Control (RBAC).
RBAC allows users, groups, and service accounts to be granted access to resources on an as needed basis.
Actions performed by each identity can be logged for auditing with Kubernetes audit policies.

Additionally some default cluster local account credentials are enabled by default.
When enabled, an identity with permissions can perform cluster actions using local account credentials.
If local account credentials are used, Kubernetes auditing logs the local account instead of named accounts.

In an AKS cluster with local account disabled administrator will be unable to get the clusterAdmin credential.
For example, using `az aks get-credentials -g '<resource-group>' -n '<cluster-name>' --admin` will fail.

## RECOMMENDATION

Consider enforcing usage of named accounts by disabling local Kubernetes account credentials.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.disableLocalAccounts` to `true`.

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
        "kubernetesVersion": "[parameters('kubernetesVersion')]",
        "disableLocalAccounts": true,
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

- Set `properties.disableLocalAccounts` to `true`.

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
    kubernetesVersion: kubernetesVersion
    disableLocalAccounts: true
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
az aks update -n '<name>' -g '<resource_group>' --enable-aad --aad-admin-group-object-ids '<aad-group-id>' --disable-local
```

## NOTES

This Azure feature is currently in preview.
To use this feature you must first opt-in by registering the feature on a per-subscription basis.

## LINKS

- [Authorization with Azure AD](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authorization)
- [Security design principles](https://learn.microsoft.com/azure/architecture/framework/security/security-principles)
- [Disable local accounts (preview)](https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts-preview)
- [Access and identity options for Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/concepts-identity#azure-ad-integration)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#managedclusterproperties-object)

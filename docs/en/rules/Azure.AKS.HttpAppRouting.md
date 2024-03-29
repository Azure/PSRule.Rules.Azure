---
reviewed: 2021/12/10
severity: Important
pillar: Security
category: Application endpoints
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.HttpAppRouting/
---

# Disable HTTP application routing add-on

## SYNOPSIS

Disable HTTP application routing add-on in AKS clusters.

## DESCRIPTION

The HTTP application routing add-on is designed to quickly expose HTTP endpoints to the public internet.
This may be helpful in some limited scenarios, but should not be used in production.

When exposing application endpoints consider using an ingress controller that supports:

- Security filtering behind web application firewall (WAF).
- Encyption in transit over TLS.
- Multiple replicas.

Azure provides a production ready ingress controller _Application Gateway Ingress Controller_ (AGIC).

## RECOMMENDATION

Consider disabling the HTTP application routing add-on in your AKS cluster.
Also consider using Application Gateway Ingress Controller (AGIC) instead to protect application endpoints.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `Properties.addonProfiles.httpApplicationRouting.enabled` to `false`.

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

- Set `Properties.addonProfiles.httpApplicationRouting.enabled` to `false`.

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

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [HTTP application routing](https://learn.microsoft.com/azure/aks/http-application-routing)
- [Enable Application Gateway Ingress Controller add-on for an existing AKS cluster](https://learn.microsoft.com/azure/application-gateway/tutorial-ingress-controller-add-on-existing)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#ManagedClusterAutoUpgradeProfile)

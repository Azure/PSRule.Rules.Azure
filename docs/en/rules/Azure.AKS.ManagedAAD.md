---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.ManagedAAD/
---

# Enable AKS-managed Azure AD

## SYNOPSIS

Use AKS-managed Azure AD to simplify authorization and improve security.

## DESCRIPTION

AKS-managed integration provides an easy way to use Azure AD authorization for AKS.
Previous Azure AD integration with AKS required app registration and management within Azure AD.

## RECOMMENDATION

Consider configuring AKS-managed Azure AD integration for AKS clusters.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.aadProfile.managed` to `true`.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2024-02-01",
  "name": "[parameters('name')]",
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
      "dnsServiceIP": "[variables('dnsServiceIP')]"
    },
    "apiServerAccessProfile": {
      "authorizedIPRanges": [
        "0.0.0.0/32"
      ]
    },
    "autoUpgradeProfile": {
      "upgradeChannel": "stable"
    },
    "oidcIssuerProfile": {
      "enabled": true
    },
    "addonProfiles": {
      "azurepolicy": {
        "enabled": true
      },
      "omsagent": {
        "enabled": true,
        "config": {
          "logAnalyticsWorkspaceResourceID": "[parameters('workspaceId')]"
        }
      },
      "azureKeyvaultSecretsProvider": {
        "enabled": true,
        "config": {
          "enableSecretRotation": "true"
        }
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName'))]"
  ]
}
```

### Configure with Bicep

To deploy AKS clusters that pass this rule:

- Set `properties.aadProfile.managed` to `true`.

For example:

```bicep
resource cluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  location: location
  name: name
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
    }
    apiServerAccessProfile: {
      authorizedIPRanges: [
        '0.0.0.0/32'
      ]
    }
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    addonProfiles: {
      azurepolicy: {
        enabled: true
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
        }
      }
    }
  }
}
```

<!-- external:avm avm/res/container-service/managed-cluster aadProfileManaged -->

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --enable-aad --aad-admin-group-object-ids '<group_id>'
```

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Security design principles](https://learn.microsoft.com/azure/architecture/framework/security/security-principles)
- [Access and identity options for Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/concepts-identity#azure-ad-integration)
- [AKS-managed Azure Active Directory integration](https://learn.microsoft.com/azure/aks/managed-aad)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#ManagedClusterAADProfile)

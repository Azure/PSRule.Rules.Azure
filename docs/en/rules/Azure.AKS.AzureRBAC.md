---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AzureRBAC/
---

# Use Azure RBAC for Kubernetes Authorization

## SYNOPSIS

Use Azure RBAC for Kubernetes Authorization with AKS clusters.

## DESCRIPTION

Azure Kubernetes Service (AKS) supports Role-based Access Control (RBAC).
RBAC is supported using Kubernetes RBAC and optionally Azure RBAC.

- Using Kubernetes RBAC, you can grant users, groups, and service accounts access to cluster resources.
- Additionally AKS supports granting Azure AD identities access to cluster resources using Azure RBAC.

Using authorization provided by Azure RBAC simplifies and centralizes authorization of Azure AD principals.
Access to Kubernetes resource can be managed using Azure Resource Manager (ARM).

When Azure RBAC is enabled:

- Azure AD principals will be validated exclusively by Azure RBAC.
- Kubernetes users and service accounts are exclusively validated by Kubernetes RBAC.

## RECOMMENDATION

Consider using Azure RBAC for Kubernetes Authorization to centralize authorization of Azure AD principals.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.aadProfile.enableAzureRBAC` to `true`.

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

- Set `properties.aadProfile.enableAzureRBAC` to `true`.

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

<!-- external:avm avm/res/container-service/managed-cluster aadProfileEnableAzureRBAC -->

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --enable-azure-rbac
```

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Use Azure RBAC for Kubernetes Authorization](https://learn.microsoft.com/azure/aks/manage-azure-rbac)
- [Access and identity options for Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/concepts-identity#azure-rbac-for-kubernetes-authorization)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

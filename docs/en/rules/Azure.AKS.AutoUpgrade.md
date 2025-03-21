---
reviewed: 2024-03-25
severity: Important
pillar: Operational Excellence
category: OE:09 Task automation
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters
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

- Set `properties.autoUpgradeProfile.upgradeChannel` to an upgrade channel such as `stable`.

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

<!-- external:avm avm/res/container-service/managed-cluster autoUpgradeProfileUpgradeChannel -->

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --auto-upgrade-channel 'stable'
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Kubernetes Service Clusters should enable cluster auto-upgrade](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Kubernetes/AKS_Autoupgrade_Cluster_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/5c345cdf-2049-47e0-b8fe-b0e96bc2df35`

## LINKS

- [OE:09 Task automation](https://learn.microsoft.com/azure/well-architected/operational-excellence/automate-tasks)
- [Supported Kubernetes versions in Azure Kubernetes Service](https://learn.microsoft.com/azure/aks/supported-kubernetes-versions)
- [Support policies for Azure Kubernetes Service](https://learn.microsoft.com/azure/aks/support-policies)
- [Automatically upgrade an Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/azure/aks/auto-upgrade-cluster)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

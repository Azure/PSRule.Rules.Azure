---
severity: Important
pillar: Performance Efficiency
category: Application scalability
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.StandardLB/
---

# Use the Standard load balancer SKU

## SYNOPSIS

Azure Kubernetes Clusters (AKS) should use a Standard load balancer SKU.

## DESCRIPTION

When deploying an AKS cluster, either a Standard or Basic load balancer SKU can be configured.
A Standard load balancer SKU is required for several AKS features including:

- Multiple node pools
- Availability zones
- Authorized IP ranges

These features improve the scalability and reliability of the cluster.

AKS clusters can not be updated to use a Standard load balancer SKU after deployment.
For switch to an Standard load balancer SKU, the cluster must be redeployed.

## RECOMMENDATION

Consider using Standard load balancer SKU during AKS cluster creation.
Additionally, consider redeploying the AKS clusters with a Standard load balancer SKU configured.

## EXAMPLES

### Configure with Azure template

To deploy clusters that pass this rule:

- Set the `properties.networkProfile.loadBalancerSku` property to `standard`.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2023-04-01",
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
    "identity"
  ]
}
```

### Configure with Bicep

To deploy clusters that pass this rule:

- Set the `properties.networkProfile.loadBalancerSku` property to `standard`.

For example:

```bicep
resource cluster 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
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

## LINKS

- [Plan for growth](https://learn.microsoft.com/azure/well-architected/scalability/design-scale#plan-for-growth)
- [Use a Standard SKU load balancer in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/load-balancer-standard)
- [LoadBalancer annotations](https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/#loadbalancer-annotations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

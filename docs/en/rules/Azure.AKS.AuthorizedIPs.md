---
reviewed: 2024-02-07
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AuthorizedIPs/
---

# Restrict access to AKS API server endpoints

## SYNOPSIS

Restrict access to API server endpoints to authorized IP addresses.

## DESCRIPTION

In Kubernetes, the API server is the control plane of the cluster.
Access to the API server is required by various cluster functions as well as all administrator activities.

All activities performed against the cluster require authorization.
To improve cluster security, the API server can be restricted to a limited set of IP address ranges.

Restricting authorized IP addresses for the API server has the following limitations:

- Requires AKS clusters configured with a Standard Load Balancer SKU.
- This feature is not compatible with clusters that use Public IP per Node.
- This feature is not compatible with AKS private clusters.

When configuring this feature, you must specify the IP address ranges that will be authorized.
To allow only the outbound public IP of the Standard SKU load balancer, use `0.0.0.0/32`.

You should add these ranges to the allow list:

- Include output IP addresses for cluster nodes
- Any range where administration will connect to the API server, including CI/CD systems, monitoring, and management systems.

## RECOMMENDATION

Consider restricting network traffic to the API server endpoints to trusted IP addresses.

## EXAMPLES

### Configure with Azure template

To deploy clusters that pass this rule:

- Set the `properties.apiServerAccessProfile.authorizedIPRanges` property to a list of authorized IP ranges.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2023-11-01",
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

To deploy resource that pass this rule:

- Set the `properties.apiServerAccessProfile.authorizedIPRanges` property to a list of authorized IP ranges.

For example:

```bicep
resource cluster 'Microsoft.ContainerService/managedClusters@2023-11-01' = {
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

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --api-server-authorized-ip-ranges '0.0.0.0/32'
```

### Configure with Azure PowerShell

```powershell
Set-AzAksCluster -Name '<name>' -ResourceGroupName '<resource_group>' -ApiServerAccessAuthorizedIpRange '0.0.0.0/32'
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Secure access to the API server using authorized IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/api-server-authorized-ip-ranges)
- [Best practices for cluster security and upgrades in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/operator-best-practices-cluster-security#secure-access-to-the-api-server-and-cluster-nodes)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

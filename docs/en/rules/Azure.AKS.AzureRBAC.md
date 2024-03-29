---
severity: Important
pillar: Security
category: Identity and access management
resource: Azure Kubernetes Service
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
    "comments": "Azure Kubernetes Cluster",
    "apiVersion": "2020-12-01",
    "dependsOn": [
        "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName'))]"
    ],
    "type": "Microsoft.ContainerService/managedClusters",
    "location": "[parameters('location')]",
    "name": "[parameters('clusterName')]",
    "identity": {
        "type": "UserAssigned",
        "userAssignedIdentities": {
            "[resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', parameters('identityName'))]": {}
        }
    },
    "properties": {
        "kubernetesVersion": "[parameters('kubernetesVersion')]",
        "disableLocalAccounts": true,
        "enableRBAC": true,
        "dnsPrefix": "[parameters('dnsPrefix')]",
        "agentPoolProfiles": [
            {
                "name": "system",
                "osDiskSizeGB": 32,
                "count": 3,
                "minCount": 3,
                "maxCount": 10,
                "enableAutoScaling": true,
                "maxPods": 50,
                "vmSize": "Standard_D2s_v3",
                "osType": "Linux",
                "type": "VirtualMachineScaleSets",
                "vnetSubnetID": "[variables('clusterSubnetId')]",
                "mode": "System",
                "osDiskType": "Ephemeral",
                "scaleSetPriority": "Regular"
            }
        ],
        "aadProfile": {
            "managed": true,
            "enableAzureRBAC": true,
            "adminGroupObjectIDs": "[parameters('clusterAdmins')]",
            "tenantID": "[subscription().tenantId]"
        },
        "networkProfile": {
            "networkPlugin": "azure",
            "networkPolicy": "azure",
            "loadBalancerSku": "Standard",
            "serviceCidr": "192.168.0.0/16",
            "dnsServiceIP": "192.168.0.4",
            "dockerBridgeCidr": "172.17.0.1/16"
        },
        "autoUpgradeProfile": {
            "upgradeChannel": "stable"
        },
        "addonProfiles": {
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
            }
        }
    }
}
```

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --enable-azure-rbac
```

## LINKS

- [Authorization with Azure AD](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authorization)
- [Use Azure RBAC for Kubernetes Authorization](https://learn.microsoft.com/azure/aks/manage-azure-rbac)
- [Access and identity options for Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/concepts-identity#azure-rbac-for-kubernetes-authorization)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

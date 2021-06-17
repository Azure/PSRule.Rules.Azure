---
severity: Important
pillar: Security
category: Identity and access management
resource: Azure Kubernetes Service
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/en/rules/Azure.AKS.LocalAccounts.md
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
az aks update -n '<name>' -g '<resource_group>' --enable-aad --aad-admin-group-object-ids '<aad-group-id>' --disable-local
```

## NOTES

This Azure feature is currently in preview.
To use this feature you must first opt-in by registering the feature on a per-subscription basis.

## LINKS

- [Authorization with Azure AD](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authorization)
- [Security design principles](https://docs.microsoft.com/azure/architecture/framework/security/security-principles)
- [Disable local accounts (preview)](https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts-preview)
- [Access and identity options for Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/concepts-identity#azure-ad-integration)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#managedclusterproperties-object)

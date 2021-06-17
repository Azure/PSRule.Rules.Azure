---
severity: Important
pillar: Security
category: Identity and access management
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/en/rules/Azure.AKS.ManagedAAD.md
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
az aks update -n '<name>' -g '<resource_group>' --enable-aad --aad-admin-group-object-ids '<group_id>'
```

## LINKS

- [Authorization with Azure AD](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authorization)
- [Security design principles](https://docs.microsoft.com/azure/architecture/framework/security/security-principles)
- [Access and identity options for Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/concepts-identity#azure-ad-integration)
- [AKS-managed Azure Active Directory integration](https://docs.microsoft.com/azure/aks/managed-aad)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#ManagedClusterAADProfile)

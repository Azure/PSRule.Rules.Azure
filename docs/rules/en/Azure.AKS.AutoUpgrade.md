---
severity: Important
pillar: Reliability
category: Design
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.AutoUpgrade.md
---

# Set AKS auto-upgrade channel

## SYNOPSIS

Configure AKS to automatically upgrade to newer supported AKS versions as they are made available.

## DESCRIPTION

In additional to performing manual upgrades, AKS supports auto-upgrades.
Auto-upgrades reduces manual intervention required to maintain a AKS cluster.

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

### EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Set `properties.autoUpgradeProfile.upgradeChannel` to an upgrade channel such as `stable`.

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
az aks update -n '<name>' -g '<resource_group>' --auto-upgrade-channel 'stable'
```

## NOTES

This Azure feature is currently in preview.
To use this feature you must first opt-in by registering the feature on a per-subscription basis.

## LINKS

- [Automation overview](https://docs.microsoft.com/azure/architecture/framework/devops/automation-overview)
- [Supported Kubernetes versions in Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/supported-kubernetes-versions)
- [Support policies for Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/support-policies)
- [Set auto-upgrade channel](https://docs.microsoft.com/azure/aks/upgrade-cluster#set-auto-upgrade-channel)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#ManagedClusterAutoUpgradeProfile)

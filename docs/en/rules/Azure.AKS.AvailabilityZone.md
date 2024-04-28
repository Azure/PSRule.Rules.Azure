---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AvailabilityZone/
---

# AKS clusters should use Availability zones in supported regions

## SYNOPSIS

AKS clusters deployed with virtual machine scale sets should use availability zones in supported regions for high availability.

## DESCRIPTION

AKS clusters using availability zones improve reliability and ensure availability during failure scenarios affecting a data center within a region.
Nodes in one availability zone are physically separated from nodes defined in another availability zone.
By spreading node pools across multiple zones, nodes in one node pool will continue running even if another zone has gone down.

## RECOMMENDATION

Consider using availability zones for AKS clusters deployed with virtual machine scale sets.

## NOTES

This rule applies when analyzing resources deployed to Azure using *pre-flight* and *in-flight* data.

This rule fails when `"availabilityZones"` is `null`, `[]` or not set when the AKS cluster is deployed to a virtual machine scale set and there are supported availability zones for the given region.

Configure `AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST` to set additional availability zones that need to be supported which are not in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers/) for namespace `Microsoft.Compute` and resource type `virtualMachineScaleSets`.

```yaml
# YAML: The default AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

## EXAMPLES

### Configure with Azure template

To set availability zones for an AKS cluster:

- Set `properties.agentPoolProfiles[*].availabilityZones` to any or all of `["1", "2", "3"]`.
- Set `properties.agentPoolProfiles[*].type` to `VirtualMachineScaleSets`.

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
                "scaleSetPriority": "Regular",
                "availabilityZones": [
                    "1",
                    "2",
                    "3"
                ]
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

#### Create AKS Cluster in Zone 1, 2 and 3

```bash
az aks create \
  --resource-group '<resource_group>' \
  --name '<cluster_name>' \
  --generate-ssh-keys \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --node-count '<node_count>' \
  --zones 1 2 3
```

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Create an Azure Kubernetes Service (AKS) cluster that uses availability zones](https://learn.microsoft.com/azure/aks/availability-zones)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

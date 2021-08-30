---
severity: Important
pillar: Security
category: Monitor
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AuditLogs/
---

# AKS clusters should collect security-based audit logs

## SYNOPSIS

AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads.

## DESCRIPTION

To capture security-based audit logs from AKS clusters, the following diagnostic logs should be enabled:

- Either `kube-audit` or `kube-audit-admin`, or both. The `kube-audit` category contains all audit log data for every audit event, including get, list, create, update, delete, patch, and post.The `kube-audit-admin` category is a subset of the `kube-audit` log category. `kube-audit-admin` reduces the number of logs significantly by excluding the get and list audit events from the log.
- `guard`. Needs to be enabled if Active Directory is enabled.

## RECOMMENDATION

Consider configuring diagnostic settings sto capture security-based audit logs from AKS clusters.

## EXAMPLES

### Configure with Azure template

To deploy AKS clusters that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for the `kube-audit`/`kube-audit-admin` and `guard` categories.

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
    },
    "resources": [
        {
            "apiVersion": "2016-09-01",
            "type": "Microsoft.ContainerService/managedClusters/providers/diagnosticSettings",
            "name": "[concat(parameters('clusterName'), '/Microsoft.Insights/service')]",
            "properties": {
                "workspaceId": "[parameters('workspaceId')]",
                "logs": [
                    {
                        "category": "kube-audit",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    },
                    {
                        "category": "kube-audit-admin",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    },
                    {
                        "category": "guard",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    }
                ],
                "metrics": []
            }
        }
    ]
}
```

## LINKS

- [Security audits](https://docs.microsoft.com/azure/architecture/framework/security/monitor-audit)
- [Collect resource logs](https://docs.microsoft.com/azure/aks/monitor-aks#collect-resource-logs)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings?tabs=json)
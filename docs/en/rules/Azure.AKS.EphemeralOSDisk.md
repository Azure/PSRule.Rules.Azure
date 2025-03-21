---
severity: Important
pillar: Performance Efficiency
category: Performance efficiency checklist
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters,Microsoft.ContainerService/managedClusters/agentPools
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.EphemeralOSDisk/
---

# Use AKS Ephemeral OS disk

## SYNOPSIS

AKS clusters should use ephemeral OS disks which can provide lower read/write latency, along with faster node scaling and cluster upgrades.

## DESCRIPTION

By default, Azure automatically replicates the operating system disk for a virtual machine to Azure storage to avoid data loss if the VM needs to be relocated to another host.
However, since containers aren't designed to have local state persisted, this behavior offers limited value while providing some drawbacks, including slower node provisioning and higher read/write latency.

By contrast, ephemeral OS disks are stored only on the host machine, just like a temporary disk.
This provides lower read/write latency, along with faster node scaling and cluster upgrades.

Like the temporary disk, an ephemeral OS disk is included in the price of the virtual machine, so you incur no additional storage costs.

NB: When a user does not explicitly request managed disks for the OS, AKS will default to ephemeral OS if possible for a given node pool configuration.
The rule is therefore configured with `-Level Warning` as it can give inaccurate information.

When using ephemeral OS, the OS disk must fit in the VM cache.
The sizes for VM cache are available in the [Azure documentation](https://learn.microsoft.com/azure/virtual-machines/dv2-dsv2-series) in parentheses next to IO throughput ("cache size in GiB").

Examples:

- Using the AKS default VM size Standard_DS2_v2 with the default OS disk size of 100GB as an example, this VM size supports ephemeral OS but only has 86GB of cache size.
  This configuration would default to managed disks if the user does not specify explicitly.
  If a user explicitly requested ephemeral OS, they would receive a validation error.
- If a user requests the same Standard_DS2_v2 with a 60GB OS disk, this configuration would default to ephemeral OS: the requested size of 60GB is smaller than the maximum cache size of 86GB.

## RECOMMENDATION

AKS clusters should use ephemeral OS disks.

## EXAMPLES

### Configure with Azure template

To deploy an AKS cluster that pass this rule:

- Set `properties.agentPoolProfiles.osDiskType` to `Ephemeral`.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2022-06-02-preview",
  "name": "[parameters('clusterName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Basic",
    "tier": "Paid"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "dnsPrefix": "[parameters('dnsPrefix')]",
    "agentPoolProfiles": [
      {
        "name": "agentpool",
        "osDiskSizeGB": 60,
        "count": "[parameters('agentCount')]",
        "vmSize": "[parameters('agentVMSize')]",
        "osDiskType": "Ephemeral",
        "osType": "Linux",
        "mode": "System"
      }
    ],
    "linuxProfile": {
      "adminUsername": "[parameters('linuxAdminUsername')]",
      "ssh": {
        "publicKeys": [
          {
            "keyData": "[parameters('sshRSAPublicKey')]"
          }
        ]
      }
    }
  }
}
```

To deploy an AKS agent pool that pass this rule:

- Set `properties.osDiskType` to `Ephemeral`.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters/agentPools",
  "apiVersion": "2022-07-01",
  "name": "[format('{0}/{1}', parameters('clusterName'), variables('poolName'))]",
  "properties": {
    "count": "[variables('minCount')]",
    "vmSize": "[variables('vmSize')]",
    "osDiskSizeGB": 60,
    "osType": "Linux",
    "osDiskType": "Ephemeral",
    "maxPods": 50,
    "mode": "User"
  },
  "dependsOn": [
    "[resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName'))]"
  ]
}
```

### Configure with Bicep

To deploy an AKS cluster that pass this rule:

- Set `properties.agentPoolProfiles.osDiskType` to `Ephemeral`.

For example:

```bicep
resource aks 'Microsoft.ContainerService/managedClusters@2022-06-02-preview' = {
  name: clusterName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Paid'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 60
        count: agentCount
        vmSize: agentVMSize
        osDiskType: 'Ephemeral'
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}
```

To deploy an AKS agent pool that pass this rule:

- Set `properties.osDiskType` to `Ephemeral`.

For example:

```bicep
resource userPool 'Microsoft.ContainerService/managedClusters/agentPools@2022-07-01' = {
  parent: cluster
  name: poolName
  properties: {
    count: minCount
    vmSize: vmSize
    osDiskSizeGB: 60
    osType: 'Linux'
    osDiskType: 'Ephemeral'
    maxPods: 50
    mode: 'User'
  }
}
```

## LINKS

- [Performance efficiency checklist](https://learn.microsoft.com/azure/architecture/framework/scalability/performance-efficiency)
- [Azure Kubernetes Service (AKS) Ephemeral OS](https://learn.microsoft.com/azure/aks/cluster-configuration#ephemeral-os)
- [Azure deployment reference (managedclusters)](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)
- [Azure deployment reference (agentpools)](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters/agentpools)

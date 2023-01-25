---
severity: Important
pillar: Reliability
category: Requirements
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.UptimeSLA/
---

# Use AKS Uptime SLA

## SYNOPSIS

AKS clusters should have Uptime SLA enabled to ensure availability of control plane components for production workloads.

## DESCRIPTION

Uptime SLA is a tier to enable a financially backed, higher SLA for an AKS cluster.
Clusters with Uptime SLA, come with greater amount of control plane resources and automatically scaling.
Uptime SLA guarantees 99.95% availability of the Kubernetes API server endpoint for clusters that use Availability Zones.
Uptime SLA guarantees 99.9% of availability for clusters that don't use Availability Zones.
AKS uses master node replicas across update and fault domains to ensure SLA requirements are met.

AKS recommends use of Uptime SLA in production workloads to ensure availability of control plane components.
Clusters on the Free SKU tier support fewer replicas and limited resources for the control plane.

## RECOMMENDATION

Consider enabling Uptime SLA for production deployments.

## EXAMPLES

### Configure with Azure template

To deploy an AKS cluster that pass this rule:

- Set `sku.tier` to `Paid`.

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
        "osDiskSizeGB": "[parameters('osDiskSizeGB')]",
        "count": "[parameters('agentCount')]",
        "vmSize": "[parameters('agentVMSize')]",
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

### Configure with Bicep

To deploy an AKS cluster that pass this rule:

- Set `sku.tier` to `Paid`.

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
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
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

## LINKS

- [Target and non-functional requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [Azure Kubernetes Service (AKS) Uptime SLA](https://docs.microsoft.com/azure/aks/uptime-sla)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

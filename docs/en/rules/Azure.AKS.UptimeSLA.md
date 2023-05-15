---
severity: Important
pillar: Reliability
category: Requirements
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.UptimeSLA/
---

# Use AKS Uptime SLA

## SYNOPSIS

AKS clusters should have Uptime SLA enabled for a financially backed SLA.

## DESCRIPTION

Azure Kubernetes Service (AKS) offers two pricing tiers for cluster management.

The `Standard` tier is suitable for financially backed SLA scenarios as it enables Uptime SLA by default on the cluster.

Benefits:

- The Free tier SKU imposes in-flight request limits of 50 mutating and 100 read-only calls. The Standard tier SKU automatically scales out based on the load.
- The Free tier SKU is recommended only for cost-sensitive non-production workloads with 10 or fewer agent nodes. The Standard tier SKU configures more resources for the control plane and will dynamically scale to handle the request load from more nodes.
- AKS recommends the use of the Standard tier for production workloads to ensure availability of control plane components. Clusters on the Free tier, by contrast come with limited resources for the control plane and are not suitable for production workloads.
- Uptime SLA guarantees 99.95% availability of the Kubernetes API server endpoint for clusters that use Availability Zones.
- Uptime SLA guarantees 99.9% of availability for clusters that don't use Availability Zones.
- AKS uses master node replicas across update and fault domains to ensure SLA requirements are met.

## RECOMMENDATION

Consider enabling Uptime SLA for a financially backed SLA.

## EXAMPLES

### Configure with Azure template

To deploy an AKS cluster that pass this rule:

- Set `sku.tier` to `Standard`.

For example:

```json
{
  "type": "Microsoft.ContainerService/managedClusters",
  "apiVersion": "2023-02-01",
  "name": "[parameters('clusterName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Basic",
    "tier": "Standard"
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

- Set `sku.tier` to `Standard`.

For example:

```bicep
resource aks 'Microsoft.ContainerService/managedClusters@2023-02-01' = {
  name: clusterName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Standard'
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

## NOTES

`Basic` and `Paid` are removed in the `2023-02-01` and `2023-02-02 Preview` API version, and this will be a breaking change in API versions `2023-02-01` and `2023-02-02 Preview` or newer.

## LINKS

- [Target and non-functional requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [Azure Kubernetes Service (AKS) Uptime SLA](https://learn.microsoft.com/azure/aks/free-standard-pricing-tiers#uptime-sla-terms-and-conditions)
- [Free and Standard pricing tiers for Azure Kubernetes Service (AKS) cluster management](https://learn.microsoft.com/azure/aks/free-standard-pricing-tiers)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#managedclustersku)

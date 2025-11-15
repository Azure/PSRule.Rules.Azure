---
reviewed: 2025-10-26
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters,Microsoft.ContainerService/managedClusters/agentPools
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.SystemPoolNaming/
---

# AKS system node pool resources must use standard naming

## SYNOPSIS

AKS system node pool resources without a standard naming convention may be difficult to identify and manage.

## DESCRIPTION

An effective naming convention allows operators to quickly identify resources, related systems, and their purpose.
Identifying resources easily is important to improve operational efficiency, reduce the time to respond to incidents,
and minimize the risk of human error.

Some of the benefits of using standardized tagging and naming conventions are:

- They provide consistency and clarity for resource identification and discovery across the Azure Portal, CLIs, and APIs.
- They enable filtering and grouping of resources for billing, monitoring, security, and compliance purposes.
- They support resource lifecycle management, such as provisioning, decommissioning, backup, and recovery.

For example, if you come upon a security incident, it's critical to quickly identify affected systems,
the functions that those systems support, and the potential business impact.

For AKS system node pool, the Cloud Adoption Framework (CAF) recommends using the `npsystem` prefix.

Requirements for AKS system node pool resource names:

- Between 1 and 12 characters long.
- Lowercase letters and numbers
- Can't start with a number.

## RECOMMENDATION

Consider creating AKS system node pool resources with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy resources that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(1)
@maxLength(12)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource system 'Microsoft.ContainerService/managedClusters/agentPools@2025-07-01' = {
  parent: cluster
  name: name
  properties: {
    osDiskSizeGB: osDiskSizeGB
    minCount: 3
    maxCount: 7
    enableAutoScaling: true
    maxPods: systemPoolMaxPods
    vmSize: 'Standard_D16ds_v6'
    osType: 'Linux'
    type: 'VirtualMachineScaleSets'
    vnetSubnetID: clusterSubnetId
    mode: 'System'
    osDiskType: 'Ephemeral'
    scaleSetPriority: 'Regular'
  }
}
```

### Configure with Azure template

To deploy resources that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "metadata": {
        "description": "The name of the resource."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters/agentPools",
      "apiVersion": "2025-07-01",
      "name": "[format('{0}/{1}', parameters('name'), 'system')]",
      "properties": {
        "osDiskSizeGB": "[parameters('osDiskSizeGB')]",
        "minCount": 3,
        "maxCount": 7,
        "enableAutoScaling": true,
        "maxPods": "[parameters('systemPoolMaxPods')]",
        "vmSize": "Standard_D16ds_v6",
        "osType": "Linux",
        "type": "VirtualMachineScaleSets",
        "vnetSubnetID": "[parameters('clusterSubnetId')]",
        "mode": "System",
        "osDiskType": "Ephemeral",
        "scaleSetPriority": "Regular"
      }
    }
  ]
}
```

## NOTES

This rule does not check if AKS system node pool resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_AKS_SYSTEM_POOL_NAME_FORMAT -->

To configure this rule set the `AZURE_AKS_SYSTEM_POOL_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_AKS_SYSTEM_POOL_NAME_FORMAT: '^npsystem'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters/agentpools)

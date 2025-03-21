---
reviewed: 2024-01-12
severity: Critical
pillar: Performance Efficiency
category: PE:03 Selecting services
resource: Databricks
resourceType: Microsoft.Databricks/workspaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Databricks.SKU/
---

# Ensure Databricks workspaces are non-trial SKUs for production workloads

## SYNOPSIS

Ensure Databricks workspaces are non-trial SKUs for production workloads.

## DESCRIPTION

An Azure Databricks workspace has three available SKU types to support the compute demands of a workspace.

The Trial SKU is a time-bound offer which has feature and compute limitations, making it unsuitable for production workloads.
*NB* - The Trial SKU is a strong candidate for non-production or innovation workloads which can accept the tiers constraints.

## RECOMMENDATION

Consider configuring Databricks workspaces to use either Standard or Premium tiers,
dependant on the workload demands and non-functional requirements (NFRs).

## EXAMPLES

### Configure with Azure template

To deploy workspaces that pass this rule:

- Set the `sku.name` to a a non-trial tier, i.e. `standard`.

For example:

```json
{
  "type": "Microsoft.Databricks/workspaces",
  "apiVersion": "2023-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "standard"
  },
  "properties": {
    "managedResourceGroupId": "[subscriptionResourceId('Microsoft.Resources/resourceGroups', 'example-mg')]",
    "publicNetworkAccess": "Disabled",
    "parameters": {
      "enableNoPublicIp": {
        "value": true
      }
    }
  }
}
```

### Configure with Bicep

To deploy workspaces that pass this rule:

- Set the `sku.name` to a a non-trial tier, i.e. `standard`.

For example:

```bicep
resource databricks 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    managedResourceGroupId: managedRg.id
    publicNetworkAccess: 'Disabled'
    parameters: {
      enableNoPublicIp: {
        value: true
      }
    }
  }
}
```

## LINKS

- [PE:03 Selecting services](https://learn.microsoft.com/azure/well-architected/performance-efficiency/select-services)
- [Databricks Setup](https://learn.microsoft.com/azure/databricks/getting-started)
- [Databricks Tier Features](https://azure.microsoft.com/pricing/details/databricks)
- [Databricks Workspace API](https://learn.microsoft.com/azure/templates/Microsoft.Databricks/workspaces)
- [Azure Databricks architecture overview](https://learn.microsoft.com/azure/databricks/getting-started/overview)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.databricks/workspaces)

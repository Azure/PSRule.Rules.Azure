---
reviewed: 2023-07-26
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Databricks
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Databricks.SecureConnectivity/
---

# Enable secure connectivity for Databricks workspaces

## SYNOPSIS

Use Databricks workspaces configured for secure cluster connectivity.

## DESCRIPTION

An Azure Databricks workspace uses one or more runtime clusters to execute data processing workloads.

When configuring Databricks workspaces, runtime clusters can be configured with or without public IP addresses.
_Secure cluster connectivity_ is used when a Databricks workspace is deployed without public IP addresses.
Use secure cluster connectivity to simplify security and administration of Databricks networking within Azure.

With secure cluster connectivity enabled:

- An outbound connection over HTTPS from the runtime cluster is used to communicate to the control plane.
- No open ports or IP public addressing is required.

## RECOMMENDATION

Consider configuring Databricks workspaces to use secure cluster connectivity.

## EXAMPLES

### Configure with Azure template

To deploy workspaces that pass this rule:

- Set the `properties.parameters.enableNoPublicIp.value` property to `true`.

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

- Set the `properties.parameters.enableNoPublicIp.value` property to `true`.

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

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)  
- [Secure cluster connectivity (No Public IP / NPIP)](https://learn.microsoft.com/azure/databricks/security/network/secure-cluster-connectivity)
- [Network access](https://learn.microsoft.com/azure/databricks/security/network/)
- [Azure Databricks architecture overview](https://learn.microsoft.com/azure/databricks/getting-started/overview)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.databricks/workspaces)

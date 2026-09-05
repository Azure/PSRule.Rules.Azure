---
reviewed: 2025-11-04
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: File Shares
resourceType: Microsoft.Kusto/clusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Share.PublicAccess/
---

# Disable public network access on File Shares clusters

## SYNOPSIS

Azure File Shares (Shares) clusters should have public network access disabled.

## DESCRIPTION

Disabling public network access improves security by ensuring that the cluster isn't exposed on the public internet.
You can control exposure of your clusters by creating private endpoints instead.

## RECOMMENDATION

Consider disabling public network access on Azure File Shares clusters, using private endpoints to control connectivity.

## EXAMPLES

### Configure with Azure template

To deploy File Shares clusters that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.

For example:

```json
{
  "type": "Microsoft.Kusto/clusters",
  "apiVersion": "2024-04-13",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_D11_v2",
    "tier": "Standard"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "publicNetworkAccess": "Disabled"
  }
}
```

### Configure with Bicep

To deploy File Shares clusters that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.

For example:

```bicep
resource adx 'Microsoft.Kusto/clusters@2024-04-13' = {
  name: name
  location: location
  sku: {
    name: 'Standard_D11_v2'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableDiskEncryption: true
    publicNetworkAccess: 'Disabled'
  }
}
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Security: Level 4](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level4)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.kusto/clusters)

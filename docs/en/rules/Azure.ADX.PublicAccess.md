---
reviewed: 2025-11-04
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Data Explorer
resourceType: Microsoft.Kusto/clusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ADX.PublicAccess/
---

# Disable public network access on Data Explorer clusters

## SYNOPSIS

Azure Data Explorer (ADX) clusters should have public network access disabled.

## DESCRIPTION

Disabling public network access improves security by ensuring that the cluster isn't exposed on the public internet.
You can control exposure of your clusters by creating private endpoints instead.

## RECOMMENDATION

Consider disabling public network access on Azure Data Explorer clusters, using private endpoints to control connectivity.

## EXAMPLES

### Configure with Azure template

To deploy Data Explorer clusters that pass this rule:

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
    "enableDiskEncryption": true,
    "publicNetworkAccess": "Disabled"
  }
}
```

### Configure with Bicep

To deploy Data Explorer clusters that pass this rule:

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
- [Security: Level 1](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level1)
- [Restrict public access to your Azure Data Explorer cluster](https://learn.microsoft.com/azure/data-explorer/security-network-restrict-public-access)
- [Azure security baseline for Azure Data Explorer](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-data-explorer-security-baseline)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-data-explorer-security-baseline#ns-2-secure-cloud-services-with-network-controls)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.kusto/clusters)

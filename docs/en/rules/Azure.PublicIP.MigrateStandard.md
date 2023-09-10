---
reviewed: 2023-09-10
severity: Important
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Public IP address
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PublicIP.MigrateStandard/
---

# Migrate to Standard SKU

## SYNOPSIS

Use the Standard SKU for Public IP addresses as the Basic SKU will be retired.

## DESCRIPTION

The Basic SKU for Public IP addresses will be retired on September 30, 2025.
To avoid service disruption, migrate to Standard SKU for Public IP addresses.

The Standard SKU additionally offers security by default and supports redundancy.

## RECOMMENDATION

Migrate Basic SKU for Public IP addresses to the Standard SKU before retirement to avoid service disruption.

## EXAMPLES

### Configure with Azure template

To deploy Public IP addresses that pass this rule:

- Set `sku.name` to `Standard`.

For example:

```json
{
  "type": "Microsoft.Network/publicIPAddresses",
  "apiVersion": "2023-05-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard",
    "tier": "Regional"
  },
  "properties": {
    "publicIPAddressVersion": "IPv4",
    "publicIPAllocationMethod": "Static",
    "idleTimeoutInMinutes": 4
  },
  "zones": [
    "1",
    "2",
    "3"
  ]
}
```

### Configure with Bicep

To deploy Public IP addresses that pass this rule:

- Set `sku.name` to `Standard`.

For example:

```bicep
resource pip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

## LINKS

- [Infrastructure provisioning](https://learn.microsoft.com/azure/well-architected/devops/automation-infrastructure)
- [Basic SKU will be retired](https://azure.microsoft.com/updates/upgrade-to-standard-sku-public-ip-addresses-in-azure-by-30-september-2025-basic-sku-will-be-retired)
- [Migrate a Basic SKU Public IP address to Standard SKU](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-basic-upgrade-guidance)
- [Standard vs Basic SKU comparison](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-addresses#sku)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/publicipaddresses#publicipaddresssku)

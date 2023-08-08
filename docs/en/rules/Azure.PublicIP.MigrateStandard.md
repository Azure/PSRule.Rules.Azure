---
severity: Important
pillar: Operational Excellence
category: Infrastructure provisioning
resource: Public IP address
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PublicIP.MigrateStandard/
---

# Migrate to Standard SKU

## SYNOPSIS

Use the Standard SKU for Public IP addresses. Basic SKU for Public IP addresses will be retired.

## DESCRIPTION

The Basic SKU for Public IP addresses will be retired on September 30, 2025. To avoid service disruption, migrate to Standard SKU for Public IP addresses.

The Standard SKU aditionally offers security by default and supports redundancy.

## RECOMMENDATION

Migrate Basic SKU for Public IP addresses to the Standard SKU before retirement to avoid service disruption.

## EXAMPLES

### Configure with Azure template

To deploy Public IP adresses that pass this rule:

- Set `sku.name` to `Standard`.

For example:

```json
{
  "type": "Microsoft.Network/publicIPAddresses",
  "apiVersion": "2023-04-01",
  "name": "[parameters('name')]",
  "location": "[resourceGroup().location]",
  "properties": {
    "sku": {
      "name": "Standard",
      "tier": "Regional"
    }
  }
}
```

### Configure with Bicep

To deploy Public IP adresses that pass this rule:

- Set `sku.name` to `Standard`.

For example:

```bicep
resource pip 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}
```

## LINKS

- [Infrastructure provisioning](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Basic SKU will be retired](https://azure.microsoft.com/updates/upgrade-to-standard-sku-public-ip-addresses-in-azure-by-30-september-2025-basic-sku-will-be-retired)
- [Migrate a Basic SKU Public IP address to Standard SKU](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-basic-upgrade-guidance)
- [Standard vs Basic SKU comparison](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-addresses#sku)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/publicipaddresses#publicipaddresssku)

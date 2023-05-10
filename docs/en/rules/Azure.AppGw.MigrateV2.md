---
severity: Important
pillar: Operational Excellence
category: Infrastructure provisioning
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.MigrateV2/
---

# Migrate to Application Gateway v2

## SYNOPSIS

Use a Application Gateway v2 SKU.

## DESCRIPTION

The Application Gateway v1 SKUs (Standard and WAF) will be retired on April 28, 2026. To avoid service disruption, migrate to Application Gateway v2 SKUs.

The v2 SKUs offers performance enhancements, security controls and adds support for critical new features like autoscaling, zone redundancy, support for static VIPs, header rewrite, key vault integration, mutual authentication (mTLS), Azure Kubernetes Service ingress controller and private link.

## RECOMMENDATION

Migrate deprecated v1 Application Gateways to a v2 SKU before retirement to avoid service disruption.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set `properties.sku.tier` to `Standard_v2` (Application Gateway) or `WAF_v2` (Web Application Firewall).

For example:

```json
{
  "name": "[parameters('name')]",
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2022-07-01",
  "location": "[resourceGroup().location]",
  "properties": {
    "sku": {
      "capacity": 2,
      "name": "WAF_v2",
      "tier": "WAF_v2"
    }
  }
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Set `properties.sku.tier` to `Standard_v2` (Application Gateway) or `WAF_v2` (Web Application Firewall).

For example:

```bicep
resource appGw 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: 
  location: location
  properties: {
    sku: {
      capacity: 2
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
  }
}
```

## NOTES

This rule is applicable for both Application Gateways and Application Gateways with Web Application Firewall (WAF).

Not all existing features under the v1 SKUs are supported in the v2 SKUs. The v2 SKUs are not currently available in all regions.

## LINKS

- [Infrastructure provisioning](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Migrate your Application Gateways](https://learn.microsoft.com/azure/application-gateway/v1-retirement)
- [What is Azure Application Gateway v2?](https://learn.microsoft.com/azure/application-gateway/overview-v2)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways#applicationgatewaysku)

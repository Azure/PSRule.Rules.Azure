---
severity: Important
pillar: Performance Efficiency
category: Design for performance
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.CDN.IsStandardSKUOrPremiumSKU/
---

# Use Standard Or Premium SKU

## SYNOPSIS

Use the latest version of Azure Front Door Standard and Premium Client Library or SDK to fix issues.

## DESCRIPTION

The latest version of Azure Front Door Standard and Premium Client Library or SDK contains fixes to issues reported by customers and proactively identified through our QA process.
The latest version also carries reliability and performance optimization in addition to new features that can improve your overall experience using Azure Front Door Standard and Premium.

## RECOMMENDATION

Use Front Door Standard or Premium SKU.

## EXAMPLES

### Configure with Azure template

To deploy an front door profile that pass this rule:

- Set `sku.name` to `Standard_AzureFrontDoor` or `Premium_AzureFrontDoor`.

For example:

```json
{
  "type": "Microsoft.Cdn/profiles",
  "apiVersion": "2022-05-01-preview",
  "name": "myFrontDoor",
  "location": "global",
  "sku": {
    "name": "Standard_AzureFrontDoor"
  }
}
```

### Configure with Bicep

To deploy an front door profile that pass this rule:

- Set `sku.name` to `Standard_AzureFrontDoor` or `Premium_AzureFrontDoor`.

For example:

```bicep
resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: 'myFrontDoor'
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}
```

## LINKS

- [Target and non-functional requirements](https://docs.microsoft.com/azure/advisor/advisor-reference-performance-recommendations)
- [Azure Front Door tiers](https://docs.microsoft.com/azure/frontdoor/standard-premium/tier-comparison)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.cdn/profiles)

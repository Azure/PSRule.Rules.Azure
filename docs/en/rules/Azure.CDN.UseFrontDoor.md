---
severity: Important
pillar: Performance Efficiency
category: Performance efficiency checklist
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.CDN.UseFrontDoor/
---

# Use Front Door Standard Or Premium SKU

## SYNOPSIS

Use Azure Front Door Standard or Premium SKU to improve the performance of web pages with dynamic content and overall capabilities.

## DESCRIPTION

Using a CDN is a good way to minimize the load on your application, and maximize availability and performance.

Standard content delivery network (CDN) capability includes the ability to cache files closer to end users to speed up delivery of static files.
However, with dynamic web applications, caching that content in edge locations isn't possible because the server generates the content in response to user behavior.
Speeding up the delivery of such content is more complex than traditional edge caching and requires an end-to-end solution that finely tunes each element along the entire data path from inception to delivery.
With Azure CDN dynamic site acceleration (DSA) optimization, the performance of web pages with dynamic content is measurably improved.

Azure Front Door Standard or Premium SKU offers modern cloud Content Delivery Network (CDN).
These SKUs in particular provides fast, reliable, and secure access between users and dynamic web content across the globe.

Azure CDN Standard from Microsoft (classic) will be retired on September 30, 2027.

## RECOMMENDATION

Consider using Front Door Standard or Premium SKU to improve performance.

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

- [Performance efficiency checklist](https://learn.microsoft.com/azure/architecture/framework/scalability/performance-efficiency)
- [Azure Front Door tiers](https://learn.microsoft.com/azure/frontdoor/standard-premium/tier-comparison)
- [What are the comparisons between Azure CDN product features?](https://learn.microsoft.com/azure/cdn/cdn-features)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles)

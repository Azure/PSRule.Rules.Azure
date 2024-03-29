---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ResourceLocation/
---

# Use a location parameter for regional resources

## SYNOPSIS

Template resource location should be an expression or `global`.

## DESCRIPTION

The template parameter `location` is a standard parameter recommended for deployment templates.
The `location` parameter is a intended for specifying the deployment location of the primary resource.

When defining a resource that requires a location, use the `location` parameter. For example:

```json
{
    "type": "Microsoft.Network/virtualNetworks",
    "name": "[parameters('VNETName')]",
    "apiVersion": "2020-06-01",
    "location": "[parameters('location')]",
    "properties": {}
}
```

Additionally, the template may include other resources.
Use the `location` parameter value for resources that are likely to be in the same location.
This approach minimizes the number of times users are asked to provide location information.
For resources that aren't available in all locations, use a separate parameter.

For non-regional resources such as Front Door and DNS Zones specify a literal location `global`.

## RECOMMENDATION

Consider updating the resource `location` property to use `[parameters('location)]`.

## LINKS

- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#location-recommendations-for-parameters)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
- [Parameters](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)

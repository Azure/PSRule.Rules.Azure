---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.UseLocationParameter.md
---

# Use a location parameter to specify resource location

## SYNOPSIS

Template should reference a location parameter to specify resource location.

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

## RECOMMENDATION

Consider using `parameters('location)` instead of `resourceGroup().location`.
Using a location parameter enabled users of the template to specify the location of deployed resources.

## LINKS

- [ARM template best practices](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#location-recommendations-for-parameters)
- [Parameters](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)
- [Release deployment](https://docs.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)

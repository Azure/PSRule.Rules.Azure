---
severity: Important
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.LocationType.md
---

# Use type string for location parameters

## SYNOPSIS

Location parameters should use a string value.

## DESCRIPTION

The template parameter `location` is a standard parameter recommended for deployment templates.
The `location` parameter is a intended for specifying the deployment location of the primary resource.
When including location parameters in templates use the type `string`.

Additionally, the template may include other resources.
Use the `location` parameter value for resources that are likely to be in the same location.
This approach minimizes the number of times users are asked to provide location information.

## RECOMMENDATION

Consider updating the `location` parameter to be of type `string`.

## LINKS

- [ARM template best practices](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#location-recommendations-for-parameters)
- [Release deployment](https://docs.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)

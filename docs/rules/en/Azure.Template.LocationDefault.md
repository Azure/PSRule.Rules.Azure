---
severity: Awareness
pillar: Reliability
category: Resource deployment
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.LocationDefault.md
---

# Default to resource group location

## SYNOPSIS

Set the default value for the location parameter within an ARM template to resource group location.

## DESCRIPTION

In the event of a regional outage in the resource group location,
you will be unable to control resources inside that resource group,
regardless of what region those resources are actually in.
Resources for regional services should be deployed into a resource group on the same region.

When authoring templates, the resource group location should be the default resource location.
This approach minimizes the number of times users are asked to provide location information.

## RECOMMENDATION

Consider updating the `location` parameter to use `[resourceGroup().location]` as the default value.

## LINKS

[ARM template best practices](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#location-recommendations-for-parameters)
[Operating in multiple regions](https://docs.microsoft.com/azure/architecture/framework/resiliency/app-design#operating-in-multiple-regions)

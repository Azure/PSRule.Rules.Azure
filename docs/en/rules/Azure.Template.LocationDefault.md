---
severity: Awareness
pillar: Reliability
category: Resource deployment
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.LocationDefault/
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

## EXAMPLES

### Configure with Azure template

To author templates that pass this rule:

- If the `location` parameter is specified, it should be set to `[resourceGroup().location]`.

For example:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]",
            "metadata": {
                "description": "The location resources will be deployed."
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Network/networkSecurityGroups",
            "apiVersion": "2021-02-01",
            "name": "nsg-001",
            "location": "[parameters('location')]",
            "properties": {
                "securityRules": [
                    {
                        "name": "deny-hop-outbound",
                        "properties": {
                            "priority": 200,
                            "access": "Deny",
                            "protocol": "Tcp",
                            "direction": "Outbound",
                            "sourceAddressPrefix": "VirtualNetwork",
                            "destinationAddressPrefix": "*",
                            "destinationPortRanges": [
                                "3389",
                                "22"
                            ]
                        }
                    }
                ]
            }
        }
    ]
}
```

### Configure with Bicep

To author bicep source files that pass this rule:

- If the `location` parameter is specified, it should be set to `resourceGroup().location`.

For example:

```bicep
@description('The location resources will be deployed.')
param location string = resourceGroup().location
```

## NOTES

This rule ignores templates using tenant, Management Group, and Subscription deployment schemas.
Deployment to these scopes does not occur against a resource group.

## LINKS

- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#location-recommendations-for-parameters)
- [Operating in multiple regions](https://learn.microsoft.com/azure/architecture/framework/resiliency/app-design#operating-in-multiple-regions)
- [Resource group](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#resource-group)

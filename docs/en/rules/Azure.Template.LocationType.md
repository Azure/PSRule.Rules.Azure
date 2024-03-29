---
severity: Important
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.LocationType/
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

## EXAMPLES

### Configure with Azure template

To author templates that pass this rule:

- If the `location` parameter is specified, it should be set to a `string` type.

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

- If the `location` parameter is specified, it should be set to a `string` type.

For example:

```bicep
@description('The location resources will be deployed.')
param location string = resourceGroup().location
```

## LINKS

- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#location-recommendations-for-parameters)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)

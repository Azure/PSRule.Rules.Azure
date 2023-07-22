---
reviewed: 2023-07-22
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Firewall
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Firewall.Name/
---

# Use valid Firewall names

## SYNOPSIS

Firewall names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Firewall names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Firewall names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Firewall naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Azure template

To deploy firewalls that pass this rule:

- Set the `name` property to align to resource naming requirements.

For example:

```json
{
  "type": "Microsoft.Network/azureFirewalls",
  "apiVersion": "2023-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "sku": {
      "name": "AZFW_VNet",
      "tier": "Premium"
    },
    "firewallPolicy": {
      "id": "[resourceId('Microsoft.Network/firewallPolicies', format('{0}_policy', parameters('name')))]"
    }
  },
  "dependsOn": [
    "firewall_policy"
  ]
}
```

### Configure with Bicep

To deploy firewalls that pass this rule:

- Set the `name` property to align to resource naming requirements.

For example:

```bicep
resource firewall 'Microsoft.Network/azureFirewalls@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    firewallPolicy: {
      id: firewall_policy.id
    }
  }
}
```

## NOTES

This rule does not check if Firewall names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Resource naming and tagging decision guide](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming-and-tagging-decision-guide)
- [Abbreviation examples for Azure resources](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/azurefirewalls)

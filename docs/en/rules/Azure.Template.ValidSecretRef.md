---
severity: Awareness
pillar: Operational Excellence
category: OE:05 Infrastructure as code
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ValidSecretRef/
---

# Use a valid secret reference

## SYNOPSIS

Use a valid secret reference within parameter files.

## DESCRIPTION

When referencing secrets in a template parameter file:

- The secret reference must be a valid Azure resource ID Key Vault.
- A secret name must be specified.
- An optional secret version can be specified.

## RECOMMENDATION

Check the secret value Key Vault reference is valid.

## EXAMPLES

### Configure with Azure template

To define Azure template parameter files that pass this rule:

- When a secret is referenced from Key Vault, provide a valid resource ID and secret name.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "gatewayName": {
      "value": "gateway-A"
    },
    "sku": {
      "value": "VpnGw1"
    },
    "subnetId": {
      "value": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet"
    },
    "sharedKey": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/kv-001"
        },
        "secretName": "valid-secret"
      }
    }
  }
}
```

## LINKS

- [OE:05 Infrastructure as code](https://learn.microsoft.com/azure/well-architected/operational-excellence/infrastructure-as-code-design)
- [Reference secrets with static ID](https://learn.microsoft.com/azure/azure-resource-manager/templates/key-vault-parameter#reference-secrets-with-static-id)
- [Create Resource Manager parameter file](https://learn.microsoft.com/azure/azure-resource-manager/templates/parameter-files)

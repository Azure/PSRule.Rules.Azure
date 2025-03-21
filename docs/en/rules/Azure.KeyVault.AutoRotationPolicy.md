---
reviewed: 2025-02-27
severity: Important
pillar: Security
category: SE:09 Application secrets
resource: Key Vault
resourceType: Microsoft.KeyVault/vaults,Microsoft.KeyVault/vaults/keys
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.AutoRotationPolicy/
---

# Key Vault key rotation policy is not set

## SYNOPSIS

Keys that become compromised may be used to spoof, decrypt, or gain access to sensitive data.

## DESCRIPTION

Automated key rotation in Key Vault allows users to configure Key Vault to automatically generate a new
key version at a specified frequency.

Key rotation is often a cause of many application outages.
It's critical that the rotation of keys be scheduled and automated to ensure effectiveness.

## RECOMMENDATION

Consider enabling auto-rotation on Key Vault keys.

## EXAMPLES

### Configure with Azure template

To set auto-rotation for a key:

- Set the `properties.rotationPolicy.lifetimeActions[*].action.type` property to `Rotate`.
- Set the `properties.rotationPolicy.lifetimeActions[*].trigger.timeAfterCreate` property to a time duration such as `P30D`.

For example:

```json
{
  "type": "Microsoft.KeyVault/vaults/keys",
  "apiVersion": "2021-06-01-preview",
  "name": "[concat(parameters('vaultName'), '/', 'key1')]",
  "properties": {
    "keyOps": [
      "sign",
      "verify",
      "wrapKey",
      "unwrapKey",
      "encrypt",
      "decrypt"
    ],
    "keySize": 2048,
    "kty": "RSA",
    "rotationPolicy": {
      "lifetimeActions": [
        {
          "action": {
            "type": "Rotate"
          },
          "trigger": {
            "timeAfterCreate": "P18D"
          }
        },
        {
          "action": {
            "type": "Notify"
          },
          "trigger": {
            "timeAfterCreate": "P30D"
          }
        }
      ]
    }
  }
}
```

### Configure with Bicep

To set auto-rotation for a key:

- Set the `properties.rotationPolicy.lifetimeActions[*].action.type` property to `Rotate`.
- Set the `properties.rotationPolicy.lifetimeActions[*].trigger.timeAfterCreate` property to a time duration such as `P30D`.

For example:

```bicep
resource vaultName_key1 'Microsoft.KeyVault/vaults/keys@2021-06-01-preview' = {
  parent: vaultName_resource
  name: 'key1'
  properties: {
    keyOps: [
      'sign'
      'verify'
      'wrapKey'
      'unwrapKey'
      'encrypt'
      'decrypt'
    ]
    keySize: 2048
    kty: 'RSA'
    rotationPolicy: {
      lifetimeActions: [
        {
          action: {
            type: 'rotate'
          }
          trigger: {
            timeAfterCreate: 'P18D'
          }
        }
        {
          action: {
            type: 'notify'
          }
          trigger: {
            timeAfterCreate: 'P30D'
          }
        }
      ]
    }
  }
}
```

## NOTES

This rule only applies to pre-flight validation of Azure templates and Bicep files.

## LINKS

- [SE:09 Application secrets](https://learn.microsoft.com/azure/well-architected/security/application-secrets)
- [IM-3: Manage application identities securely and automatically](https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-identity-management#im-3-manage-application-identities-securely-and-automatically)
- [Configure cryptographic key auto-rotation in Azure Key Vault](https://learn.microsoft.com/azure/key-vault/keys/how-to-configure-key-rotation)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults/keys)

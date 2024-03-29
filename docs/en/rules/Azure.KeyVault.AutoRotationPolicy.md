---
reviewed: 2022-09-09
severity: Important
pillar: Security
category: Key and secret management
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.AutoRotationPolicy/
---

# Enable Key Vault key auto-rotation

## SYNOPSIS

Key Vault keys should have auto-rotation enabled.

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

- Set `properties.rotationPolicy.lifetimeActions[*].action.type` to `Rotate`.
- Set `properties.rotationPolicy.lifetimeActions[*].trigger.timeAfterCreate` to the time duration after key creation to rotate.

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

- Set `properties.rotationPolicy.lifetimeActions[*].action.type` to `Rotate`.
- Set `properties.rotationPolicy.lifetimeActions[*].trigger.timeAfterCreate` to the time duration
after key creation to rotate.

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

## LINKS

- [Operational considerations](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-keys#operational-considerations)
- [IM-3: Manage application identities securely and automatically](https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-identity-management#im-3-manage-application-identities-securely-and-automatically)
- [Configure cryptographic key auto-rotation in Azure Key Vault](https://learn.microsoft.com/azure/key-vault/keys/how-to-configure-key-rotation)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/vaults/keys)

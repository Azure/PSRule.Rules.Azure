---
severity: Important
pillar: Security
category: Security design principles
resource:  Recovery Services Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RSV.Immutable/
---

# Immutability

## SYNOPSIS

Ensure immutability is configured to protect backup data.

## DESCRIPTION

Immutability is supported for Recovery Services vaults by configuring the Immutable vault setting.

Immutable vault helps protecting backup data by blocking any operations that could lead to loss of recovery points. Additionally, locking the Immutable vault setting makes it irreversible to prevent any malicious actors from disabling immutability and deleting backups.

The Immutable vault setting is not enabled per default.

## RECOMMENDATION

Consider configuring immutability to protect backup data.

## EXAMPLES

### Configure with Azure template

To deploy Recovery Services vaults that pass this rule:

- Set `properties.securitySettings.immutabilitySettings.state` to `Unlocked` or `Locked`.

For example:

```json
{
  "type": "Microsoft.RecoveryServices/vaults",
  "apiVersion": "2023-01-01",
  "name": "[parameters('vaultName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('skuName')]",
    "tier": "[parameters('skuTier')]"
  },
  "properties": {
    "securitySettings": {
      "immutabilitySettings": {
        "state": "Locked"
      }
    }
  }
}
```

### Configure with Bicep

To deploy Recovery Services vaults that pass this rule:

- Set `properties.securitySettings.immutabilitySettings.state` to `Unlocked` or `Locked`.

For example:

```bicep
resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2023-01-01' = {
  name: vaultName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    securitySettings: {
      immutabilitySettings: {
        state: 'Locked'
      }
    }
  }
}
```

## NOTES

Note that immutability locking `Locked` is irreversible, so ensure to take a well-informed decision when opting to lock.

## LINKS

- [Security design principles](https://learn.microsoft.com/azure/well-architected/security/security-principles)
- [Immutable vault for Azure Backup](https://learn.microsoft.com/azure/backup/backup-azure-immutable-vault-concept)
- [Restricted operations](https://learn.microsoft.com/azure/backup/backup-azure-immutable-vault-concept#restricted-operations)
- [Manage Azure Backup Immutable vault operations](https://learn.microsoft.com/azure/backup/backup-azure-immutable-vault-how-to-manage)
- [Azure security baseline for Azure Backup](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/backup-security-baseline)
- [DP-2: Protect sensitive data](https://learn.microsoft.com/security/benchmark/azure/baselines/backup-security-baseline#dp-2-protect-sensitive-data)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.recoveryservices/vaults#securitysettings)

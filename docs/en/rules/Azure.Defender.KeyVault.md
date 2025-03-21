---
reviewed: 2023-02-19
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Microsoft Defender for Cloud
resourceType: Microsoft.Security/pricings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.KeyVault/
---

# Set Microsoft Defender for Key Vault to the Standard tier

## SYNOPSIS

Enable Microsoft Defender for Key Vault.

## DESCRIPTION

Microsoft Defender for Key Vault provides additional protection for keys and secrets stored in Key Vaults.
It does this by detecting unusual and potentially harmful attempts to access or exploit Key Vault accounts.
This protection is provided by analyzing telemetry from Key Vault and Microsoft Defender for Cloud.

When anomalous activities occur, Defender for Key Vault shows alerts to relevant members of your organization.
These alerts include the details of the suspicious activity and recommendations on how to investigate and remediate threats.

Microsoft Defender for Key Vault can be enabled at the subscription level for all Key Vaults in the subscription.
Azure Policy can be used to automatically enable Microsoft Defender for Key Vault a subscription.

## RECOMMENDATION

Consider using Microsoft Defender for Key Vault to provide additional protection to Key Vaults.

## EXAMPLES

### Configure with Azure template

To enable Microsoft Defender for Key Vault:

- Set the `Standard` pricing tier for Microsoft Defender for Key Vault.

For example:

```json
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2024-01-01",
  "name": "KeyVaults",
  "properties": {
    "pricingTier": "Standard"
  }
}
```

### Configure with Bicep

To enable Microsoft Defender for Key Vault:

- Set the `Standard` pricing tier for Microsoft Defender for Key Vault.

For example:

```bicep
resource defenderForKeyVaults 'Microsoft.Security/pricings@2024-01-01' = {
  name: 'KeyVaults'
  properties: {
    pricingTier: 'Standard'
  }
}
```

<!-- external:avm avm/ptn/security/security-center keyVaultsPricingTier -->

### Configure with Azure CLI

To enable Microsoft Defender for Key Vault:

- Set the `Standard` pricing tier for Microsoft Defender for Key Vault.

For example:

```bash
az security pricing create -n 'KeyVaults' --tier 'standard'
```

### Configure with Azure PowerShell

To enable Microsoft Defender for Key Vault:

- Set the `Standard` pricing tier for Microsoft Defender for Key Vault.

For example:

```powershell
Set-AzSecurityPricing -Name 'KeyVaults' -PricingTier 'Standard'
```

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [What is Microsoft Defender for Cloud?](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Overview of Microsoft Defender for Key Vault](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-key-vault-introduction)
- [Quickstart: Enable enhanced security features](https://learn.microsoft.com/azure/defender-for-cloud/enable-enhanced-security)
- [Azure security baseline for Key Vault](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline)
- [LT-1: Enable threat detection capabilities](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline#lt-1-enable-threat-detection-capabilities)
- [Azure Policy built-in policy definitions](https://learn.microsoft.com/azure/governance/policy/samples/built-in-policies#security-center)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/pricings)

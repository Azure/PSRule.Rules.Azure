---
severity: Critical
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Firewall
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Firewall.PolicyMode/
---

# Threat intelligence-based filtering

## SYNOPSIS

Deny high confidence malicious IP addresses, domains and URLs.

## DESCRIPTION

Threat intelligence-based filtering can optionally be enabled on Azure Firewall, by associating one or more policies with threat intelligence-based filtering configured.

When configured, Azure Firewall alerts and deny traffic to/from known malicious IP addresses, domains and URLs.

By default, threat intelligence-based filtering is enabled and in `alert` mode on each policy unless otherwise is specified.

By configuring threat intelligence-based filtering in `alert and deny` mode, threat intelligence-based filtering may deny traffic before any configured rules are processed.

## RECOMMENDATION

Consider configuring Azure Firewall to alert and deny IP addresses, domains and URLs detected as malicious.

### Configure with Azure template

To deploy Azure Firewall polices that pass this rule:

- Set the `properties.threatIntelMode` property to `Deny`.

For example:

```json
{
  "type": "Microsoft.Network/firewallPolicies",
  "apiVersion": "2023-04-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "sku": {
      "tier": "Premium"
    },
    "threatIntelMode": "Deny"
  }
}
```

### Configure with Bicep

To deploy Azure Firewall polices that pass this rule:

- Set the `properties.threatIntelMode` property to `Deny`.

For example:

```bicep
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-04-01' = {
  name: name
  location: location
  properties: {
    sku: {
      tier: 'Premium'
    }
    threatIntelMode: 'Deny'
  }
}
```

<!-- external:avm avm/res/network/firewall-policy threatIntelMode -->

### NOTES

Azure Firewall Premium SKU is required for associating standalone resource firewall policies.
Only Standard and Premium firewall policies supports threat intelligence-based filtering in `alert and deny` mode.

In order to take advantage of URL filtering with `HTTPS` traffic included in threat intelligence-based filtering, TLS inspection must be configured first.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [NS-1: Establish network segmentation boundaries](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-firewall-security-baseline#ns-1-establish-network-segmentation-boundaries)
- [Azure Firewall threat intelligence-based filtering](https://learn.microsoft.com/azure/firewall/threat-intel)
- [Rule processing logic](https://learn.microsoft.com/azure/firewall/rule-processing#threat-intelligence)
- [Azure security baseline for Azure Firewall](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-firewall-security-baseline)
- [Azure network security overview](https://learn.microsoft.com/azure/security/fundamentals/network-overview#azure-firewall)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/firewallpolicies#firewallpolicypropertiesformat)

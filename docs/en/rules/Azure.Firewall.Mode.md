---
severity: Critical
pillar: Security
category: Network security and containment
resource: Firewall
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Firewall.Mode/
---

# Configure deny on threat intel for classic managed Azure Firewalls

## SYNOPSIS

Deny high confidence malicious IP addresses and domains on classic managed Azure Firewalls.

## DESCRIPTION

Threat intelligence-based filtering can optionally be enabled on Azure Firewall.
When enabled, Azure Firewall alerts and deny traffic to/ from known malicious IP addresses and domains.

By default, Azure Firewall alerts on triggered threat intelligence rules.

Specifically, this rule only applies using an Azure Firewall in classic management mode.
If the Azure Firewall is connected to a Secured Virtual Hub this rule will not apply.

Classic managed Azure Firewalls are standalone.
Alternatively you can manage Azure Firewalls at scale through Firewall Manager by using policy.
When using firewall policies, threat intelligence is configured centrally instead of on each firewall.

## RECOMMENDATION

Consider configuring Azure Firewall to alert and deny IP addresses and domains detected as malicious.
Alternatively, consider using firewall policies to manage Azure Firewalls at scale.

### Configure with Azure template

To deploy Azure Firewalls that pass this rule:

- Set the `properties.threatIntelMode` to `Deny`.

For example:

```json
{
    "type": "Microsoft.Network/azureFirewalls",
    "apiVersion": "2021-05-01",
    "name": "[format('{0}_classic', parameters('name'))]",
    "location": "[parameters('location')]",
    "properties": {
        "sku": {
            "name": "AZFW_VNet"
        },
        "threatIntelMode": "Deny"
    }
}
```

### Configure with Bicep

To deploy Azure Firewalls that pass this rule:

- Set the `properties.threatIntelMode` to `Deny`.

For example:

```bicep
resource firewall_classic 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: '${name}_classic'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
    }
    threatIntelMode: 'Deny'
  }
}
```

## LINKS

- [Implement network segmentation patterns on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-segmentation)
- [Azure Firewall threat intelligence-based filtering](https://learn.microsoft.com/azure/firewall/threat-intel)
- [Azure network security overview](https://learn.microsoft.com/azure/security/fundamentals/network-overview#azure-firewall)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/azurefirewalls)

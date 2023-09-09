---
severity: Important
pillar: Reliability
category: Resiliency and dependencies
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.SingleDNS/
---

# Use redundant DNS servers

## SYNOPSIS

Virtual networks (VNETs) should have at least two DNS servers assigned.

## DESCRIPTION

Virtual networks (VNETs) should have at least two (2) DNS servers assigned.
Using a single DNS server may indicate a single point of failure where the DNS IP address is not load balanced.

## RECOMMENDATION

Virtual networks should have at least two (2) DNS servers set when not using Azure-provided DNS.

## EXAMPLES

### Configure with Azure template

To deploy Virtual Networks that pass this rule:

- Set `properties.dhcpOptions.dnsServers` to at least two DNS server addresses. OR
- Use the default Azure DNS servers.

For example:

```json
{
  "type": "Microsoft.Network/virtualNetworks",
  "apiVersion": "2023-05-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "addressSpace": {
      "addressPrefixes": [
        "10.0.0.0/16"
      ]
    },
    "dhcpOptions": {
      "dnsServers": [
        "10.0.1.4",
        "10.0.1.5"
      ]
    }
  }
}
```

### Configure with Bicep

To deploy Virtual Networks that pass this rule:

- Set `properties.dhcpOptions.dnsServers` to at least two DNS server addresses. OR
- Use the default Azure DNS servers.

For example:

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        '10.0.1.4'
        '10.0.1.5'
      ]
    }
  }
}
```

## LINKS

- [Understand the impact of dependencies](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency#understand-the-impact-of-dependencies)
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure landing zone conceptual architecture](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)

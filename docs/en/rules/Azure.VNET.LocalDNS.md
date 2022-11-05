---
severity: Important
pillar: Reliability
category: Resiliency and dependencies
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.LocalDNS/
---

# Use local DNS servers

## SYNOPSIS

Virtual networks (VNETs) should use Azure local DNS servers.

## DESCRIPTION

Virtual networks allow one or more custom DNS servers to be specified.
These DNS servers that are inherited by connected services such as virtual machines.

When configuring custom DNS server IP addresses, these servers must be accessible for name resolution to occur.
Connectivity between services may be impacted if DNS server IP addresses are temporarily or permanently unavailable.

Avoid taking a dependency on external DNS servers for local communication such as those deployed on-premises.
This can be achieved by using DNS services deployed into the same Azure region.

Where possible consider deploying Azure Private DNS Zones, a platform-as-a-service (PaaS) DNS service for VNETs.
Alternativelym consider deploying redundant virtual machines (VMs) or network virtual appliances (NVA) to host DNS within Azure.

## RECOMMENDATION

Consider deploying redundant DNS services within a connected Azure VNET.

## EXAMPLES

### Configure with Azure template

To deploy Virtual Networks that pass this rule:

- Set `properties.dhcpOptions.dnsServers` to an IP address within the same or peered network within Azure. OR
- Use the default Azure DNS servers.

For example:

```json
{
  "type": "Microsoft.Network/virtualNetworks",
  "apiVersion": "2022-05-01",
  "name": "vnet-01",
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

- Set `properties.dhcpOptions.dnsServers` to an IP address within the same or peered network within Azure. OR
- Use the default Azure DNS servers.

For example:

```bicep
resource virtualnetwork01 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'vnet-01'
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

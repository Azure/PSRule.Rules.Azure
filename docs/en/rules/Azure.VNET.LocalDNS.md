---
reviewed: 2023-09-09
severity: Important
pillar: Reliability
category: Resiliency and dependencies
resource: Virtual Network
resourceType: Microsoft.Network/virtualNetworks
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.LocalDNS/
---

# Use local DNS servers

## SYNOPSIS

Virtual networks (VNETs) should use DNS servers deployed within the same Azure region.

## DESCRIPTION

Virtual networks allow one or more custom DNS servers to be specified.
These DNS servers are inherited by connected services such as virtual machines.

When configuring custom DNS server IP addresses, these servers must be accessible for name resolution to occur.
Connectivity between services may be impacted if DNS server IP addresses are temporarily or permanently unavailable.

Avoid taking a dependency on external DNS servers for local communication such as those deployed on-premises.
This can be achieved by using DNS services deployed into the same Azure region.

Where possible consider deploying:

- Azure DNS Private Resolver.
- Azure Private DNS Zones.

Alternatively, redundant virtual machines (VMs) can be deployed into Azure to perform DNS resolution.

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

- Set `properties.dhcpOptions.dnsServers` to an IP address within the same or peered network within Azure. OR
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

## NOTES

This rule applies when analyzing resources deployed to Azure (in-flight).

When deploying Active Directory Domain Services (ADDS) within Azure, you may decide to:

- Deploy an Identity subscription aligned to the Cloud Adoption Framework (CAF) Azure landing zone architecture.
- Host DNS services on the same VMs as ADDS, located in a separate VNET spoke for the Identity subscription.

When you do this, this rule may report a false positive by default.
If you are using this configuration, we recommend you set the configuration option `AZURE_VNET_DNS_WITH_IDENTITY` to `true`.

For example:

```yaml
configuration:
  AZURE_VNET_DNS_WITH_IDENTITY: true
```

## LINKS

- [Understand the impact of dependencies](https://learn.microsoft.com/azure/well-architected/resiliency/design-resiliency#understand-the-impact-of-dependencies)
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure landing zone conceptual architecture](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture)
- [What is Azure DNS Private Resolver?](https://learn.microsoft.com/azure/dns/dns-private-resolver-overview)
- [What is Azure Private DNS?](https://learn.microsoft.com/azure/dns/private-dns-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)

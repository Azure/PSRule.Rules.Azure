---
reviewed: 2022-11-05
severity: Important
pillar: Security
category: Network segmentation
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.FirewallSubnet/
---

# Configure VNETs with a AzureFirewallSubnet subnet

## SYNOPSIS

Use Azure Firewall to filter network traffic to and from Azure resources.

## DESCRIPTION

Network segementation is a key component of a secure network architecture.
Azure provides several features that work together to provide strong network segmentation controls.

Azure Firewall is a cloud native stateful Firewall as a service.
It can be used to perform deep packet inspection on both east-west and north-south traffic.
Firewalls rules can be defined as policies and centrally managed.

Some key advantages that Azure Firewall has over traditional solutions include:

- Azure Firewall integrates directly with Virtual Network (VNET) and subnet level security.
  Supports Azure concepts that minimize the need for complex network configuration such as service/ FQDN tags and load balancing.
- Managed by Azure, there is no need to deploy additional management infrastructure or consoles.
- Built-in support for Infrastructure as Code (IaC), version control, and DevOps.

## RECOMMENDATION

Consider deploying an Azure Firewall within hub networks to filter traffic between VNETs and on-premises networks.

## EXAMPLES

### Configure with Azure template

To deploy Virtual Networks that pass this rule:

- Configure an `AzureFirewallSubnet` defined in `properties.subnets`.

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
    "subnets": [
      {
        "name": "GatewaySubnet",
        "properties": {
          "addressPrefix": "10.0.0.0/27"
        }
      },
      {
        "name": "AzureFirewallSubnet",
        "properties": {
          "addressPrefix": "10.0.1.0/26"
        }
      }
    ]
  }
}
```

### Configure with Bicep

To deploy Virtual Networks that pass this rule:

- Configure an `AzureFirewallSubnet` defined in `properties.subnets`.

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
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
        }
      }
    ]
  }
}
```

## LINKS

- [Azure features for segmentation](https://learn.microsoft.com/azure/architecture/framework/security/design-network-segmentation#azure-features-for-segmentation)
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure VNET deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure subnet deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets)

---
reviewed: 2023-09-10
severity: Important
pillar: Reliability
category: Best practices
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.BastionSubnet/
---

# Configure VNETs with a AzureBastionSubnet subnet

## SYNOPSIS

VNETs with a GatewaySubnet should have an AzureBastionSubnet to allow for out of band remote access to VMs.

## DESCRIPTION

Azure Bastion lets you securely connect to a virtual machine using your browser or native SSH/RDP client on Windows workstations or the Azure portal.
An Azure Bastion host is deployed inside an Azure Virtual Network and can access virtual machines in the virtual network (VNet), or virtual machines in peered VNets.

Azure Bastion is a fully managed service that provides more secure and seamless Remote Desktop Protocol (RDP) and Secure Shell Protocol (SSH) access to virtual machines (VMs), without any exposure through public IP addresses.

This is a recommended pattern for virtual machine remote access.

Adding Azure Bastion in your configuration adds the following benefits:

- Added resiliency (out of band remote access).
- Negates the need for hybrid connectivity.
- Provides an extra layer of control.
  It enables secure and seamless RDP/SSH connectivity to your VMs directly from the Azure portal or native client in preview over a secure TLS channel.

## RECOMMENDATION

Consider an Azure Bastion Subnet to allow for out of band remote access to VMs and provide an extra layer of control.

## EXAMPLES

### Configure with Azure template

To deploy Virtual Networks that pass this rule:

- Configure an `AzureBastionSubnet` defined in `properties.subnets`.

For example:

```json
{
  "apiVersion": "2023-05-01",
  "type": "Microsoft.Network/virtualNetworks",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "addressSpace": {
      "addressPrefixes": ["10.0.0.0/16"]
    },
    "subnets": [
      {
        "name": "GatewaySubnet",
        "properties": {
          "addressPrefix": "10.0.0.0/27"
        }
      },
      {
        "name": "AzureBastionSubnet",
        "properties": {
          "addressPrefix": "10.0.1.64/26"
        }
      }
    ]
  }
}
```

To deploy Virtual Networks with a subnet sub-resource that pass this rule:

- Configure an `AzureBastionSubnet` sub-resource.

For example:

```json
{
  "apiVersion": "2023-05-01",
  "type": "Microsoft.Network/virtualNetworks/subnets",
  "name": "[format('{0}/{1}', parameters('name'), 'AzureBastionSubnet')]",
  "properties": {
    "addressPrefix": "10.0.1.64/26"
  },
  "dependsOn": ["[resourceId('Microsoft.Network/virtualNetworks', parameters('name'))]"]
}
```

### Configure with Bicep

To deploy Virtual Networks that pass this rule:

- Configure an `AzureBastionSubnet` defined in `properties.subnets`.

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
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/27'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.64/26'
        }
      }
    ]
  }
}
```

To deploy Virtual Networks with a subnet sub-resource that pass this rule:

- Configure an `AzureBastionSubnet` sub-resource.

For example:

```bicep
resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: 'AzureBastionSubnet'
  parent: vnet
  properties: {
    addressPrefix: '10.0.1.64/26'
  }
}
```

## LINKS

- [Best practices](https://learn.microsoft.com/azure/well-architected/resiliency/design-best-practices)
- [Plan for virtual machine remote access](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/plan-for-virtual-machine-remote-access)
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [What is Azure Bastion?](https://learn.microsoft.com/azure/bastion/bastion-overview)
- [Azure VNET deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure subnet deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets)

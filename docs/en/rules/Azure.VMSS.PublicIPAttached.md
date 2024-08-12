---
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.PublicIPAttached/
---

# Public IPs attached

## SYNOPSIS

Avoid attaching public IPs directly to virtual machine scale set instances.

## DESCRIPTION

Attaching a public IP address to a virtual machine network interface (NIC) exposes it directly to the Internet.
This exposure can make the virtual machine scale set instance vulnerable to unauthorized inbound access and security compromise.
Minimize the number of Internet ingress/ egress points to enhance security and reduces potential attack surfaces.

For enhanced security, consider one or more of the following options:

- **Secure remote access** &mdash; by RDP or SSH to virtual machine scale set instances can be configured through Azure Bastion.
  - Azure Bastion provides a secure encrypted connection without exposing a public IP.
- **Exposing web services** &mdash; by HTTP/S can be configured by App Gateway or Azure Front Door (AFD).
  - App Gateway and AFD provide a secure reverse proxy that supports web application firewall (WAF) filtering.
- **Internet connectivity** &mdash; should be managed through a security hardened device such as Azure Firewall.
  - This option also allows additional controls to be applied for east/ west and north/ south traffic filtering.
  - Alternatively a Network Virtual Appliance (NVA) can used.

## RECOMMENDATION

Evaluate alternative methods for inbound access to virtual machine scale set instances to enhance security and minimize risk.

### Configure with Azure template

To deploy virtual machine scale sets that pass this rule:

- For each interface configuration specified in the `properties.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.ipConfigurations` property:
  - For each IP configuration specified in the `properties.ipConfigurations` property:
    - Ensure that the `properties.publicIPAddressConfiguration.name` property does specify a public IP address.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachineScaleSets",
  "apiVersion": "2023-09-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "b2ms",
    "tier": "Standard",
    "capacity": 3
  },
  "properties": {
    "virtualMachineProfile": {
      "networkProfile": {
        "networkInterfaceConfigurations": [
          {
            "name": "nic-001",
            "properties": {
              "primary": true,
              "ipConfigurations": [
                {
                  "name": "nic-001-defaultIpConfiguration",
                  "properties": {
                    "privateIPAddressVersion": "IPv4",
                    "subnet": {
                      "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('virtualNetworkName'), parameters('subnetName'))]"
                    },
                    "primary": true
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
```

To deploy VM network interfaces that pass this rule:

- For each IP configuration specified in the `properties.ipConfigurations` property:
  - Ensure that the `properties.publicIPAddress.id` property does not reference a Public IP resource.

For example:

```json
{
  "type": "Microsoft.Network/networkInterfaces",
  "apiVersion": "2023-11-01",
  "name": "[parameters('nicName')]",
  "location": "[parameters('location')]",
  "properties": {
    "ipConfigurations": [
      {
        "name": "[parameters('ipConfig')]",
        "properties": {
          "privateIPAllocationMethod": "Dynamic",
          "subnet": {
            "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('virtualNetworkName'), parameters('subnetName'))]"
          }
        }
      }
    ]
  }
}
```

### Configure with Bicep

To deploy virtual machine scale sets that pass this rule:

- For each interface configuration specified in the `properties.virtualMachineProfle.networkProfile.networkInterfaceConfigurations.ipConfigurations` property:
  - For each IP configuration specified in the `properties.ipConfigurations` property:
    - Ensure that the `properties.publicIPAddress.id` property does not reference a Public IP resource.

For example:

```bicep
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: name
  location: location
  sku: {
    name: 'b2ms'
    tier: 'Standard'
    capacity: 3
  }
  properties: {
    virtualMachineProfile: {
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic-001'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'nic-001-defaultIpConfiguration'
                  properties: {
                    privateIPAddressVersion: 'IPv4'
                    subnet: {
                      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
                    }
                    primary: true
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
```

To deploy VM network interfaces that pass this rule:

- For each IP configuration specified in the `properties.ipConfigurations` property:
  - Ensure that the `properties.publicIPAddress.id` property does not reference a Public IP resource.

For example:

```bicep
resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ipconfig
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
  }
}
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Plan for inbound and outbound internet connectivity](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/plan-for-inbound-and-outbound-internet-connectivity)
- [Networking for scale sets](https://learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-networking)
- [Public IPv4 per virtual machine](https://learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-networking#public-ipv4-per-virtual-machine)
- [Azure Bastion](https://learn.microsoft.com/azure/bastion/bastion-overview)
- [Azure deployment reference - VMSS](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets)
- [Azure deployment reference - VMSS instance](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets/virtualmachines)
- [Azure deployment reference - NIC](https://learn.microsoft.com/azure/templates/microsoft.network/networkinterfaces)

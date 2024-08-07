---
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.PublicIPAttached/
---

# Public IPs attached

## SYNOPSIS

Avoid attaching public IPs directly to virtual machines.

## DESCRIPTION

Attaching a public IP address to a virtual machine exposes it directly to the internet. This exposure can make the VM vulnerable to unauthorized access and potential compromise if appropriate security measures are not implemented.

For enhanced security, inbound and outbound traffic should be managed through a centralized Azure Firewall or Network Virtual Appliance (NVA), ensuring control over both east/west and north/south traffic.
Minimizing the number of internet egress points enhances security and reduces potential attack surfaces.

For secure RDP and SSH access to virtual machines, consider using Azure Bastion.

## RECOMMENDATION

Evaluate alternative methods for inbound access to virtual machines to enhance security and minimize risk.

### Configure with Azure template

To deploy virtual machines that pass this rule:

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
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/virtualNetworks', parameters('virtualNetworkName'))]"
  ]
}
```

### Configure with Bicep

To deploy virtual machines that pass this rule:

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
  dependsOn: [
    virtualNetwork
  ]
}
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Plan for inbound and outbound internet connectivity](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/plan-for-inbound-and-outbound-internet-connectivity)
- [Dissociate public IP address from a VM](https://learn.microsoft.com/azure/virtual-network/ip-services/remove-public-ip-address-vm)
- [Azure Bastion](https://learn.microsoft.com/azure/bastion/bastion-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networkinterfaces)

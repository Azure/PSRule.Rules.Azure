---
reviewed: 2024-01-02
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Virtual Network
resourceType: Microsoft.Network/virtualNetworks,Microsoft.Network/virtualNetworks/subnets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.UseNSGs/
---

# Use NSGs on subnets

## SYNOPSIS

Virtual network (VNET) subnets should have Network Security Groups (NSGs) assigned.

## DESCRIPTION

Each VNET subnet should have a network security group (NSG) assigned.
NSGs are basic stateful firewalls that provide network isolation and security within a VNET.
A key benefit of NSGS is that they provide network segmentation between and within a subnet.

NSGs can be assigned to a virtual machine network interface or a subnet.
When assigning NSGs to a subnet, all network traffic within the subnet is subject to the NSG rules.

There is a small subset of special purpose subnets that do not support NSGs.
These subnets are:

- `GatewaySubnet` - used for hybrid connectivity with VPN and ExpressRoute gateways.
- `AzureFirewallSubnet` and `AzureFirewallManagementSubnet` - are for Azure Firewall.
  Azure Firewall includes an intrinsic NSG that is not directly manageable or visible.
- `RouteServerSubnet` - used by managed routing provided by Azure Route Server.
- Any subnet delegated to a dedicated HSM with `Microsoft.HardwareSecurityModules/dedicatedHSMs`.

## RECOMMENDATION

Consider assigning a network security group (NSG) to each virtual network subnet.

## EXAMPLES

### Configure with Azure template

To deploy virtual networks subnets that pass this rule:

- Set the `properties.networkSecurityGroup.id` property for each supported subnet to a NSG resource id.

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
    },
    "subnets": [
      {
        "name": "GatewaySubnet",
        "properties": {
          "addressPrefix": "10.0.0.0/24"
        }
      },
      {
        "name": "snet-001",
        "properties": {
          "addressPrefix": "10.0.1.0/24",
          "networkSecurityGroup": {
            "id": "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('nsgName'))]"
          }
        }
      }
    ]
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('nsgName'))]"
  ]
}
```

### Configure with Bicep

To deploy virtual network subnets that pass this rule:

- Set the `properties.networkSecurityGroup.id` property for each supported subnet to a NSG resource id.

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
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'snet-001'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}
```

### Configure with Azure CLI

```bash
az network vnet subnet update -n '<subnet>' -g '<resource_group>' --vnet-name '<vnet_name>' --network-security-group '<nsg_name>`
```

### Configure with Azure PowerShell

```powershell
$vnet = Get-AzVirtualNetwork -Name '<vnet_name>' -ResourceGroupName '<resource_group>'
$nsg = Get-AzNetworkSecurityGroup -Name '<nsg_name>' -ResourceGroupName '<resource_group>'
Set-AzVirtualNetworkSubnetConfig -Name '<subnet>' -VirtualNetwork $vnet -AddressPrefix '10.0.1.0/24' -NetworkSecurityGroup $nsg
```

## NOTES

If you identify a false positive for an Azure service that does not support NSGs,
please [open an issue](https://github.com/Azure/PSRule.Rules.Azure/issues/new) to help us improve this rule.

To exclude subnets that are specific to your environment, use the `AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG` configuration option.
Any subnet names specified by this option will be ignored by this rule.

For example:

```yaml
configuration:
  AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG:
  - subnet-1
  - subnet-2
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Network Security Best Practices](https://learn.microsoft.com/azure/security/fundamentals/network-best-practices#logically-segment-subnets)
- [Azure Firewall FAQ](https://learn.microsoft.com/azure/firewall/firewall-faq#are-network-security-groups--nsgs--supported-on-the-azurefirewallsubnet)
- [Forced tunneling configuration](https://learn.microsoft.com/azure/firewall/forced-tunneling#forced-tunneling-configuration)
- [Azure Route Server FAQ](https://learn.microsoft.com/azure/route-server/route-server-faq#can-i-associate-a-network-security-group-nsg-to-the-routeserversubnet)
- [Azure Dedicated HSM networking](https://learn.microsoft.com/azure/dedicated-hsm/networking#subnets)
- [NS-1: Establish network segmentation boundaries](https://learn.microsoft.com/security/benchmark/azure/baselines/virtual-network-security-baseline#ns-1-establish-network-segmentation-boundaries)
- [Azure VNET deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks?pivots=deployment-language-bicep)
- [Azure NSG deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networksecuritygroups)

---
severity: Critical
pillar: Security
category: Network security and containment
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.AnyInboundSource/
---

# Avoid rules that allow "any" as an inbound source

## SYNOPSIS

Network security groups (NSGs) should avoid rules that allow "any" as an inbound source.

## DESCRIPTION

NSGs filter network traffic for Azure services connected to a virtual network subnet.
In addition to the built-in security rules, a number of custom rules may be defined.
Custom security rules can be defined that _allow_ or _deny_ _inbound_ or _outbound_ communication.

When defining custom rules, avoid using rules that allow **any** as the inbound source.
The intent of custom rules that allow any inbound source may not be clearly understood by support teams.
Additionally, custom rules with any inbound source may expose services if a public IP address is attached.

When inbound network traffic from the Internet is intended also consider the following:

- Use Application Gateway in-front of any web application workloads.
- Use DDoS Protection Standard to protect public IP addresses.

## RECOMMENDATION

Consider updating inbound rules to use a specified source such as an IP range, application security group, or service tag.
If inbound access from Internet-based sources is intended, consider using the service tag `Internet`.

## EXAMPLES

### Configure with Azure template

To deploy Network Security Groups that pass this rule:

- Set the `sourceAddressPrefix` or `sourceAddressPrefixes` to a value other then `*` for inbound allow rules.

For example:

```json
{
  "type": "Microsoft.Network/networkSecurityGroups",
  "apiVersion": "2022-01-01",
  "name": "[parameters('nsgName')]",
  "location": "[parameters('location')]",
  "properties": {
    "securityRules": [
      {
        "name": "AllowLoadBalancerHealthInbound",
        "properties": {
          "description": "Allow inbound Azure Load Balancer health check.",
          "access": "Allow",
          "direction": "Inbound",
          "priority": 100,
          "protocol": "*",
          "sourcePortRange": "*",
          "sourceAddressPrefix": "AzureLoadBalancer",
          "destinationPortRange": "*",
          "destinationAddressPrefix": "*"
        }
      },
      {
        "name": "AllowApplicationInbound",
        "properties": {
          "description": "Allow internal web traffic into application.",
          "access": "Allow",
          "direction": "Inbound",
          "priority": 300,
          "protocol": "Tcp",
          "sourcePortRange": "*",
          "sourceAddressPrefix": "10.0.0.0/8",
          "destinationPortRange": "443",
          "destinationAddressPrefix": "VirtualNetwork"
        }
      },
      {
        "name": "DenyAllInbound",
        "properties": {
          "description": "Deny all other inbound traffic.",
          "access": "Deny",
          "direction": "Inbound",
          "priority": 4000,
          "protocol": "*",
          "sourcePortRange": "*",
          "sourceAddressPrefix": "*",
          "destinationPortRange": "*",
          "destinationAddressPrefix": "*"
        }
      },
      {
        "name": "DenyTraversalOutbound",
        "properties": {
          "description": "Deny outbound double hop traversal.",
          "access": "Deny",
          "direction": "Outbound",
          "priority": 200,
          "protocol": "Tcp",
          "sourcePortRange": "*",
          "sourceAddressPrefix": "VirtualNetwork",
          "destinationAddressPrefix": "*",
          "destinationPortRanges": [
            "3389",
            "22"
          ]
        }
      }
    ]
  }
}
```

To create an Application Security Group, use the `Microsoft.Network/applicationSecurityGroups` resource.
For example:

```json
{
  "type": "Microsoft.Network/applicationSecurityGroups",
  "apiVersion": "2022-01-01",
  "name": "[parameters('asgName')]",
  "location": "[parameters('location')]",
  "properties": {}
}
```

### Configure with Bicep

To deploy Network Security Groups that pass this rule:

- Set the `sourceAddressPrefix` or `sourceAddressPrefixes` to a value other then `*` for inbound allow rules.

For example:

```bicep
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowLoadBalancerHealthInbound'
        properties: {
          description: 'Allow inbound Azure Load Balancer health check.'
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowApplicationInbound'
        properties: {
          description: 'Allow internal web traffic into application.'
          access: 'Allow'
          direction: 'Inbound'
          priority: 300
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '10.0.0.0/8'
          destinationPortRange: '443'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          description: 'Deny all other inbound traffic.'
          access: 'Deny'
          direction: 'Inbound'
          priority: 4000
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyTraversalOutbound'
        properties: {
          description: 'Deny outbound double hop traversal.'
          access: 'Deny'
          direction: 'Outbound'
          priority: 200
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '3389'
            '22'
          ]
        }
      }
    ]
  }
}
```

To create an Application Security Group, use the `Microsoft.Network/applicationSecurityGroups` resource.
For example:

```Bicep
resource asg 'Microsoft.Network/applicationSecurityGroups@2022-01-01' = {
  name: asgName
  location:location
  properties: {}
}
```

## LINKS

- [Service Tags Overview](https://learn.microsoft.com/azure/virtual-network/service-tags-overview)
- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Network Security Groups](https://docs.microsoft.com/azure/virtual-network/security-overview)
- [Logically segment subnets](https://docs.microsoft.com/azure/security/fundamentals/network-best-practices#logically-segment-subnets)
- [What is Azure Application Gateway?](https://docs.microsoft.com/azure/application-gateway/overview)
- [Azure DDoS Protection Standard overview](https://docs.microsoft.com/azure/virtual-network/ddos-protection-overview)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/networksecuritygroups/securityrules)

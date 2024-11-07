---
severity: Important
pillar: Reliability
category: RE:01 Simplicity and efficiency
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.DenyAllInbound/
---

# Network Security Group denies all inbound traffic

## SYNOPSIS

When all inbound traffic is denied, some functions that affect the reliability of your service may not work as expected.

## DESCRIPTION

Network Security Groups (NSGs) are can be configured to block or allow network traffic by defining security rules.
Each security rule is processed in order from lowest priority to highest priority until the first match is found.
Blocking all inbound traffic will fail load balancer health probes and other required traffic.

When using a custom deny all inbound rule, also add rules to allow permitted traffic.
To permit network traffic, add a custom allow rule with a lower priority number then the deny all rule.
Rules with a lower priority number will be processed first.
100 is the lowest priority number.

## RECOMMENDATION

Consider using a higher priority number for deny all rules to allow permitted traffic rules to be added and processed first.
Consider enabling Flow Logs on all critical subnets in your subscription as an auditability and security best practice.

## EXAMPLES

### Configure with Azure template

To deploy Network Security Groups that pass this rule:

- Set the priority of rules to a number less than a deny all rule.

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

### Configure with Bicep

To deploy Network Security Groups that pass this rule:

- Set the priority of rules to a number less than a deny all rule.

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

## LINKS

- [RE:01 Simplicity and efficiency](https://learn.microsoft.com/azure/well-architected/reliability/simplify)
- [Network security groups](https://learn.microsoft.com/azure/virtual-network/security-overview)
- [Introduction to flow logging for network security groups](https://learn.microsoft.com/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
- [Virtual network service tags](https://learn.microsoft.com/azure/virtual-network/service-tags-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networksecuritygroups/securityrules)

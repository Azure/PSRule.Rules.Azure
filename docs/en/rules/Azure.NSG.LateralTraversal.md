---
severity: Important
pillar: Security
category: Network segmentation
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.LateralTraversal/
---

# Limit lateral traversal within subnets

## SYNOPSIS

Deny outbound management connections from non-management hosts.

## DESCRIPTION

Network Security Groups (NSGs) are basic stateful firewalls that provide network isolation and security.
NSGs allow or deny network traffic to and from Azure resources in an Azure virtual network.
i.e. Traffic between VMs on the same or different subnet can be restricted.
NSGs do this by enforcing ordered access rules for all traffic in or out services attached to a subnet.

This micro-segmentation approach provides a control to reduce lateral movement between services.

Typically, a subset of trusted hosts such as privileged access workstations (PAWs), bastion hosts,
or jump boxes will be used for management.
Management protocols originating from application workload hosts should be blocked.

For example:

- An SQL Server should not be used as a management host to manage other SQL Servers, or File Servers.
- Configure dedicated management hosts to manage other hosts.

This helps improve security in two ways:

1. Reduces the attack surface that can be used in lateral traversal attacks.
2. Limits the likelihood that privileged credentials will be exposed for outbound management.

## RECOMMENDATION

Consider configuring NSGs rules to block common outbound management traffic from non-management hosts.

## NOTES

Specifically this rule checks if either 3389 (RDP) or 22 (SSH) has been blocked for outbound traffic.

To suppress this rule for NSGs protecting subnets expected to allow outbound management traffic see [Permit outbound management](https://azure.github.io/PSRule.Rules.Azure/customization/permit-outbound-management/).

## EXAMPLES

### Configure with Azure template

To deploy NSGs that pass this rule:

- Add an outbound security rule that denies TCP port 3389 and/ or 22.

For example:

```json
{
    "type": "Microsoft.Network/networkSecurityGroups",
    "name": "[parameters('nsgName')]",
    "apiVersion": "2019-04-01",
    "location": "[resourceGroup().location]",
    "properties": {
        "securityRules": [
            {
                "name": "deny-hop-outbound",
                "properties": {
                    "protocol": "*",
                    "sourcePortRange": "*",
                    "destinationPortRanges": [
                        "3389",
                        "22"
                    ],
                    "access": "Deny",
                    "priority": 200,
                    "direction": "Outbound",
                    "sourceAddressPrefix": "VirtualNetwork",
                    "destinationAddressPrefix": "*"
                }
            }
        ]
    }
}
```

### Configure with Bicep

To deploy NSGs that pass this rule:

- Add an outbound security rule that denies TCP port 3389 and/ or 22.

For example:

```bicep
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'nsg-001'
  properties: {
    securityRules: [
      {
        name: 'deny-hop-outbound'
        properties: {
          priority: 200
          access: 'Deny'
          protocol: 'Tcp'
          direction: 'Outbound'
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

- [Implement network segmentation patterns on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-segmentation)
- [Logically segment subnets](https://learn.microsoft.com/azure/security/fundamentals/network-best-practices#logically-segment-subnets)
- [Plan virtual networks](https://learn.microsoft.com/azure/virtual-network/virtual-network-vnet-plan-design-arm#segmentation)
- [Network security groups](https://learn.microsoft.com/azure/virtual-network/security-overview)
- [Permit outbound management](https://azure.github.io/PSRule.Rules.Azure/customization/permit-outbound-management/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networksecuritygroups/securityrules)

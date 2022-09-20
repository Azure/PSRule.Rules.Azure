---
severity: Critical
pillar: Security
category: Network security and containment
resource: Network Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NSG.AnyInboundSource/
---

# Avoid rules that allow any inbound source

## SYNOPSIS

Network security groups (NSGs) should avoid rules that allow any inbound source.

## DESCRIPTION

NSGs filter network traffic for Azure services connected to a virtual network subnet.
In addition to the built-in security rules, a number of custom rules may be defined.
Custom security rules can be defined that _allow_ or _deny_ _inbound_ or _outbound_ communication.

When defining custom rules, avoid using rules that allow **any** inbound source.
The intent of custom rules that allow any inbound source may not be clearly understood by support teams.
Additionally, custom rules with any inbound source may expose services if a public IP address is attached.

When inbound network traffic from the Internet is intended also consider the following:

- Use Application Gateway in-front of any web application workloads.
- Use DDoS Protection Standard to protect public IP addresses.

## RECOMMENDATION

Consider updating inbound rules to use a specified source such as an IP range or service tag.
If inbound access from Internet-based sources is intended, consider using the service tag `Internet`.

## LINKS

- [Best practices for endpoint security on Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Network Security Groups](https://docs.microsoft.com/azure/virtual-network/security-overview)
- [Logically segment subnets](https://docs.microsoft.com/azure/security/fundamentals/network-best-practices#logically-segment-subnets)
- [What is Azure Application Gateway?](https://docs.microsoft.com/azure/application-gateway/overview)
- [Azure DDoS Protection Standard overview](https://docs.microsoft.com/azure/virtual-network/ddos-protection-overview)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.network/networksecuritygroups/securityrules)

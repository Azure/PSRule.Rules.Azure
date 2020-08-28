---
severity: Critical
pillar: Security
category: Network security and containment
resource: Network Security Group
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.NSG.AnyInboundSource.md
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

## RECOMMENDATION

Consider updating inbound rules to use a specified source such as an IP range or service tag.
If inbound access from Internet-based sources is intended, consider using the service tag `Internet`.

Consider using services such as Application Gateway and DDoS Protection Standard when inbound Internet access is intended.

## LINKS

- [Network Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview)
- [Logically segment subnets](https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices#logically-segment-subnets)
- [What is Azure Application Gateway?](https://docs.microsoft.com/en-us/azure/application-gateway/overview)
- [Azure DDoS Protection Standard overview](https://docs.microsoft.com/en-us/azure/virtual-network/ddos-protection-overview)

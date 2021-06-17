---
severity: Important
pillar: Security
category: Design
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/en/rules/Azure.AKS.AuthorizedIPs.md
---

# Restrict access to AKS API server endpoints

## SYNOPSIS

Restrict access to API server endpoints to authorized IP addresses.

## DESCRIPTION

In Kubernetes, the API server is the control plane of the cluster.
Access to the API server is required by various cluster functions as well as all administrator activities.

All activities performed against the cluster require authorization.
To improve cluster security, the API server can be restricted to a limited set of IP address ranges.

Restricting authorized IP addresses for the API server as the following limitations:

- Requires AKS clusters configured with a Standard Load Balancer SKU.
- This feature is not compatible with clusters that use Public IP per Node.

When configuring this feature you must specify the IP address ranges that will be authorized.
To allow only the outbound public IP of the Standard SKU load balancer, use `0.0.0.0/32`.

## RECOMMENDATION

Consider restricting network traffic to the API server endpoints to trusted IP addresses.
Include output IP addresses for cluster nodes and any range where administration will occur from.

## EXAMPLES

### Configure with Azure CLI

```bash
az aks update -n '<name>' -g '<resource_group>' --api-server-authorized-ip-ranges '0.0.0.0/32'
```

## LINKS

- [Network security](https://docs.microsoft.com/azure/architecture/framework/security/design-network)
- [Secure access to the API server using authorized IP address ranges in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/api-server-authorized-ip-ranges)
- [Best practices for cluster security and upgrades in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/operator-best-practices-cluster-security#secure-access-to-the-api-server-and-cluster-nodes)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)

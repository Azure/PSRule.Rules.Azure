---
severity: Critical
pillar: Security
category: Identity and access management
resource: Service Fabric
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceFabric.AAD/
---

# Use AAD authentication with Service Fabric clusters

## SYNOPSIS

Use Azure Active Directory (AAD) client authentication for Service Fabric clusters.

## DESCRIPTION

When deploying Service Fabric clusters on Azure, AAD can optionally be used to secure management endpoints.
If configured, client authentication (client-to-node security) uses AAD.
Additionally Azure Role-based Access Control (RBAC) can be used to delegate cluster access.

For Service Fabric clusters running on Azure, AAD is recommended to secure access to management endpoints.

## RECOMMENDATION

Consider enabling Azure Active Directory (AAD) client authentication for Service Fabric clusters.

## NOTES

For Linux clusters, AAD authentication must be configured at cluster creation time.
Windows cluster can be updated to support AAD authentication after initial deployment.

## LINKS

- [Security recommendations](https://learn.microsoft.com/azure/service-fabric/service-fabric-cluster-security#security-recommendations)
- [Set up Azure Active Directory for client authentication](https://learn.microsoft.com/azure/service-fabric/service-fabric-cluster-creation-setup-aad)
- [Configure Azure Active Directory Authentication for Existing Cluster](https://github.com/Azure/Service-Fabric-Troubleshooting-Guides/blob/master/Security/Configure%20Azure%20Active%20Directory%20Authentication%20for%20Existing%20Cluster.md)

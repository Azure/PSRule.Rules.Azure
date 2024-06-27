---
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Service Fabric
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceFabric.AAD/
---

# Use Entra ID authentication with Service Fabric clusters

## SYNOPSIS

Use Entra ID client authentication for Service Fabric clusters.

## DESCRIPTION

When deploying Service Fabric clusters on Azure,
Entra ID (previously known as Azure AD) can optionally be used to secure management endpoints.
If configured, client authentication (client-to-node security) uses Entra ID.
Additionally Azure Role-based Access Control (RBAC) can be used to delegate cluster access.

For Service Fabric clusters running on Azure, Entra ID is recommended to secure access to management endpoints.

## RECOMMENDATION

Consider enabling Entra ID client authentication for Service Fabric clusters.

## NOTES

For Linux clusters, Entra ID authentication must be configured at cluster creation time.
Windows cluster can be updated to support Entra ID authentication after initial deployment.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Security recommendations](https://learn.microsoft.com/azure/service-fabric/service-fabric-cluster-security#security-recommendations)
- [Set up Microsoft Entra ID for client authentication](https://learn.microsoft.com/azure/service-fabric/service-fabric-cluster-creation-setup-aad)
- [Configure Azure Active Directory Authentication for Existing Cluster](https://github.com/Azure/Service-Fabric-Troubleshooting-Guides/blob/master/Security/Configure%20Azure%20Active%20Directory%20Authentication%20for%20Existing%20Cluster.md)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.servicefabric/clusters)

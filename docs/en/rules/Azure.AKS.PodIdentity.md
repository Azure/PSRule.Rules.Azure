---
severity: Important
pillar: Operational Excellence
category: Configuration
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.PodIdentity/
---

# Use managed identities for AKS pod authentication

## SYNOPSIS

Configure AKS clusters to use AAD pod identities to access Azure resources securely.

## DESCRIPTION

AAD pod identities allows AKS clusters to assign a user identity to a pod in Kubernetes.

Administrators create identities and bindings as Kubernetes primitives that allow pods to access
Azure resources that rely on Azure AD as an identity provider.

## RECOMMENDATION

Consider enabling AAD pod identities on AKS clusters.

## EXAMPLES

### Configure with Azure CLI

Register `EnablePodIdentityPreview` feature:

```bash
az feature register --name EnablePodIdentityPreview --namespace Microsoft.ContainerService
```

Install the `aks-preview` Azure CLI:

```bash
# Install the aks-preview extension
az extension add --name aks-preview

# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview
```

Create AKS cluster with AAD Pod identity enabled:

```bash
az aks create -g '<resource_group>' -n '<cluster_name>' --enable-pod-identity --network-plugin azure
```

Update an existing AKS cluster with AAD pod identity enabled:

```bash
az aks update -g '<resource_group>' -n '<cluster_name>' --enable-pod-identity
```

## LINKS

- [Use identity-based authentication](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-identity-based-authentication)
- [Use Azure Active Directory pod-managed identities in Azure Kubernetes Service (Preview)](https://docs.microsoft.com/azure/aks/use-azure-ad-pod-identity)
- [Use managed identities in Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/use-managed-identity)
- [What are managed identities for Azure resources?](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
- [AAD Pod Identity](https://github.com/Azure/aad-pod-identity)
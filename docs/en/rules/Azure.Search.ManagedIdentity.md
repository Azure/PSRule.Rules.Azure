---
severity: Important
pillar: Security
category: Identity and access management
resource: Cognitive Search
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/en/rules/Azure.Search.ManagedIdentity.md
---

# Search services uses a managed identity

## SYNOPSIS

Configure managed identities to access Azure resources.

## DESCRIPTION

Connections to Azure resources is required to use some features including indexing and customer managed-keys.
Cognitive Search can use managed identities to authenticate to Azure resource without storing credentials.

Using Azure managed identities have the following benefits:

- You don't need to store or manage credentials.
Azure automatically generates tokens and performs rotation.
- You can use managed identities to authenticate to any Azure service that supports Azure AD authentication.
- Managed identities can be used without any additional cost.

## RECOMMENDATION

Consider configuring a managed identity for each Cognitive Search service.
Also consider using managed identities to authenticate to related Azure services.

## EXAMPLES

### Configure with Azure template

To deploy Cognitive Search services that pass this rule:

- Set the `identity.type` to `SystemAssigned`.

For example:

```json
{
    "apiVersion": "2020-08-01",
    "name": "[parameters('serviceName')]",
    "location": "[parameters('location')]",
    "type": "Microsoft.Search/searchServices",
    "identity": {
        "type": "SystemAssigned"
    },
    "sku": {
        "name": "[parameters('sku')]"
    },
    "properties": {
        "replicaCount": 3,
        "partitionCount": 1,
        "hostingMode": "default"
    },
    "tags": {},
    "dependsOn": []
}
```

## LINKS

- [Use identity-based authentication](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-identity-based-authentication)
- [What are managed identities for Azure resources?](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
- [Set up an indexer connection to a data source using a managed identity](https://docs.microsoft.com/azure/search/search-howto-managed-identities-data-sources)
- [Indexer access to Azure Storage using the trusted service exception (Azure Cognitive Search)](https://docs.microsoft.com/azure/search/search-indexer-howto-access-trusted-service-exception)

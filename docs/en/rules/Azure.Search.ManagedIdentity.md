---
reviewed: 2023-07-02
severity: Important
pillar: Security
category: Authentication
resource: Cognitive Search
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Search.ManagedIdentity/
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
  "type": "Microsoft.Search/searchServices",
  "apiVersion": "2022-09-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "sku": {
    "name": "standard"
  },
  "properties": {
    "replicaCount": 3,
    "partitionCount": 1,
    "hostingMode": "default"
  }
}
```

### Configure with Bicep

To deploy Cognitive Search services that pass this rule:

- Set the `identity.type` to `SystemAssigned`.

For example:

```bicep
resource search 'Microsoft.Search/searchServices@2022-09-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'standard'
  }
  properties: {
    replicaCount: 3
    partitionCount: 1
    hostingMode: 'default'
  }
}
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [What are managed identities for Azure resources?](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
- [Connect a search service to other Azure resources using a managed identity](https://learn.microsoft.com/azure/search/search-howto-managed-identities-data-sources)
- [Make indexer connections to Azure Storage as a trusted service](https://learn.microsoft.com/azure/search/search-indexer-howto-access-trusted-service-exception)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.search/searchservices)

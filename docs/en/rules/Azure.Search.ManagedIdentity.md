---
reviewed: 2024-03-16
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: AI Search
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Search.ManagedIdentity/
---

# Search services uses a managed identity

## SYNOPSIS

Configure managed identities to access Azure resources.

## DESCRIPTION

AI Search (Previously know as Cognitive Search) may require connection to other Azure resources.
Connections to Azure resources are required to use some features including indexing and customer managed-keys.
AI Search can use managed identities to authenticate to Azure resources without storing credentials.

Using Azure managed identities have the following benefits:

- You don't need to store or manage credentials.
  Azure automatically generates tokens and performs rotation.
- You can use managed identities to authenticate to any Azure service that supports Entra ID authentication.
- Managed identities can be used without any additional cost.

## RECOMMENDATION

Consider configuring a managed identity for each AI Search service.
Also consider using managed identities to authenticate to related Azure services.

## EXAMPLES

### Configure with Azure template

To deploy AI Search services that pass this rule:

- Set the `identity.type` property to `SystemAssigned`.

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

To deploy AI Search Search services that pass this rule:

- Set the `identity.type` property to `SystemAssigned`.

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

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [What are managed identities for Azure resources?](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/overview)
- [Connect a search service to other Azure resources using a managed identity](https://learn.microsoft.com/azure/search/search-howto-managed-identities-data-sources)
- [Make indexer connections to Azure Storage as a trusted service](https://learn.microsoft.com/azure/search/search-indexer-howto-access-trusted-service-exception)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.search/searchservices)

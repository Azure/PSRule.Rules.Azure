---
reviewed: 2022-05-14
severity: Important
pillar: Security
category: Authentication
resource: Data Explorer
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ADX.ManagedIdentity/
---

# Use managed identities for Data Explorer clusters

## SYNOPSIS

Configure Data Explorer clusters to use managed identities to access Azure resources securely.

## DESCRIPTION

A managed identity allows your cluster to access other Azure AD-protected resources such as Azure Storage.
The identity is managed by the Azure platform and doesn't require you to provision or rotate any secrets.

Using Azure managed identities have the following benefits:

- You don't need to store or manage credentials.
  Azure automatically generates tokens and performs rotation.
- You can use managed identities to authenticate to any Azure service that supports Azure AD authentication.
- Managed identities can be used without any additional cost.

## RECOMMENDATION

Consider configuring a managed identity for each Azure Data Explorer cluster.
Also consider using managed identities to authenticate to related Azure services.

## EXAMPLES

### Configure with Azure template

To deploy clusters that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```json
{
    "type": "Microsoft.Kusto/clusters",
    "apiVersion": "2021-08-27",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "sku": {
        "name": "Standard_D11_v2",
        "tier": "Standard"
    },
    "identity": {
        "type": "SystemAssigned"
    },
    "properties": {
        "enableDiskEncryption": true
    }
}
```

### Configure with Bicep

To deploy clusters that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource adx 'Microsoft.Kusto/clusters@2021-08-27' = {
  name: name
  location: location
  sku: {
    name: 'Standard_D11_v2'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableDiskEncryption: true
  }
}
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-identity-based-authentication)
- [Managed identities overview](https://docs.microsoft.com/azure/data-explorer/managed-identities-overview)
- [Configure managed identities for your Azure Data Explorer cluster](https://docs.microsoft.com/azure/data-explorer/configure-managed-identities-cluster)
- [Managed identities for Azure resources](https://docs.microsoft.com/azure/data-explorer/security#managed-identities-for-azure-resources)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.kusto/clusters)

---
severity: Critical
pillar: Security
category: Encryption
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.MinTLS/
---

# Azure SQL DB server minimum TLS version

## SYNOPSIS

Azure SQL Database servers should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Azure SQL Database servers accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.

## EXAMPLES

### Configure with Azure template

To deploy logical SQL Servers that pass this rule:

- Set the `properties.minimalTlsVersion` to `1.2`.

For example:

```json
{
  "type": "Microsoft.Sql/servers",
  "apiVersion": "2022-11-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "publicNetworkAccess": "Disabled",
    "minimalTlsVersion": "1.2",
    "administrators": {
      "azureADOnlyAuthentication": true,
      "administratorType": "ActiveDirectory",
      "login": "[parameters('adminLogin')]",
      "principalType": "Group",
      "sid": "[parameters('adminPrincipalId')]",
      "tenantId": "[tenant().tenantId]"
    }
  }
}
```

### Configure with Bicep

To deploy logical SQL Servers that pass this rule:

- Set the `properties.minimalTlsVersion` to `1.2`.

For example:

```bicep
resource server 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
    administrators: {
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      login: adminLogin
      principalType: 'Group'
      sid: adminPrincipalId
      tenantId: tenant().tenantId
    }
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Minimal TLS Version](https://docs.microsoft.com/azure/azure-sql/database/connectivity-settings#minimal-tls-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.sql/servers#serverproperties)

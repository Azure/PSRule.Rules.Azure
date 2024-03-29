---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.ManagedIdentity/
---

# App Service apps uses a managed identity

## SYNOPSIS

Configure managed identities to access Azure resources.

## DESCRIPTION

Azure App Service apps must authenticate to Azure resources such as Azure SQL Databases.
App Service can use managed identities to authenticate to Azure resource without storing credentials.

Using Azure managed identities have the following benefits:

- You don't need to store or manage credentials.
Azure automatically generates tokens and performs rotation.
- You can use managed identities to authenticate to any Azure service that supports Azure AD authentication.
- Managed identities can be used without any additional cost.

## RECOMMENDATION

Consider configuring a managed identity for each App Service app.
Also consider using managed identities to authenticate to related Azure services.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```json
{
    "type": "Microsoft.Web/sites",
    "apiVersion": "2021-02-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "identity": {
        "type": "SystemAssigned"
    },
    "kind": "web",
    "properties": {
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]",
        "httpsOnly": true,
        "siteConfig": {
            "alwaysOn": true,
            "minTlsVersion": "1.2",
            "ftpsState": "FtpsOnly",
            "remoteDebuggingEnabled": false,
            "http20Enabled": true
        }
    },
    "tags": "[parameters('tags')]",
    "dependsOn": [
        "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]"
    ]
}
```

### Configure with Bicep

To deploy App Services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'web'
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      remoteDebuggingEnabled: false
      http20Enabled: true
    }
  }
  tags: tags
}
```

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access#resource-identity)
- [What are managed identities for Azure resources?](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
- [Tutorial: Secure Azure SQL Database connection from App Service using a managed identity](https://learn.microsoft.com/azure/app-service/app-service-web-tutorial-connect-msi)
- [How to use managed identities for App Service and Azure Functions](https://learn.microsoft.com/azure/app-service/overview-managed-identity?tabs=dotnet)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)

---
reviewed: 2025-06-30
severity: Critical
pillar: Security
category: SE:09 Application secrets
resource: App Configuration
resourceType: Microsoft.AppConfiguration/configurationStores,Microsoft.AppConfiguration/configurationStores/keyValues
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.SecretLeak/
---

# App Configuration Store key value is secret

## SYNOPSIS

Secrets stored as key values in an App Configuration Store may be leaked to unauthorized users.

## DESCRIPTION

This rule detects cases when a sensitive value such as secret is set as a key value in an Azure App Configuration Store.
Setting a secret directly as a key value can lead to accidental exposure of sensitive information.

Azure App Configuration is a service that helps developers centrally manage application settings and feature flags.
It allows you to store key-value pairs, manage them securely at scale.

App Configuration and Azure Key Vault work together to provide a secure way to manage application secrets.
Key points about this integration include:

- The secret value is stored in Azure Key Vault.
- An App Configuration Store key value holds a reference to that secret, not the actual secret value.
- At runtime, application code retrieves the secret value from Azure Key Vault using the reference stored in App Configuration.
- Retrieving the secret value is done client side in application code.
  Azure SDKs and libraries handle the retrieval process automatically when configured.
- Access to the App Configuration Store does not grant access to the secrets stored in Azure Key Vault.
- The application code must have the necessary permissions to access the secret in Azure Key Vault using its own identity.
- Access to the Key Vault works with existing network security features such as private endpoints and service firewall.
  Network access occurs from the application code to the Key Vault, not from the App Configuration Store.

This has several benefits:

- **Reduced exposure**: Secrets are not stored directly in application configurations, reducing the risk of accidental exposure.
- **Access control**: Azure Key Vault provides fine-grained access control to individual secrets.
- **Auditability**: Access to secrets can be logged and monitored using the same mechanisms used for all other Key Vaults.
- **Centralized management**: Snapshotting and exporting of a configuration store can be done without risk of exposing secrets.

<!-- security:note rotate-secret -->

## RECOMMENDATION

Consider using Azure Key Vault to store secrets,
then reference them in your App Configuration Store instead of storing them directly as key values.

## EXAMPLES

### Configure with Bicep

To deploy key values that pass this rule:

- Create a Key Vault and a secret in it.
- Configure a key value in the App Configuration Store to a reference to the Key Vault secret by:
  - Set the `properties.contentType` property to `application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8`.
  - Set the `properties.value` property to a JSON object with a `uri` property that points to the Key Vault secret URI.

For example:

```bicep
resource vault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: 'myKeyVault'
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' existing = {
  parent: vault
  name: 'mySecret'
}

resource kvReference 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-06-01' = {
  parent: store
  name: configurationName
  properties: {
    value: '{"uri":"${secret.properties.secretUri}"}'
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}
```

### Configure with Azure template

To deploy key values that pass this rule:

- Create a Key Vault and a secret in it.
- Configure a key value in the App Configuration Store to a reference to the Key Vault secret by:
  - Set the `properties.contentType` property to `application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8`.
  - Set the `properties.value` property to a JSON object with a `uri` property that points to the Key Vault secret URI.

For example:

```json
{
  "type": "Microsoft.AppConfiguration/configurationStores/keyValues",
  "apiVersion": "2024-06-01",
  "name": "[format('{0}/{1}', parameters('name'), parameters('configurationName'))]",
  "properties": {
    "value": "{\"uri\":\"https://myKeyVault.vault.azure.net/secrets/mySecret\"}",
    "contentType": "application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8"
  },
  "dependsOn": [
    "[resourceId('Microsoft.AppConfiguration/configurationStores', parameters('name'))]"
  ]
}
```

## LINKS

- [SE:09 Application secrets](https://learn.microsoft.com/azure/well-architected/security/application-secrets)
- [IM-8: Restrict the exposure of credential and secrets](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-app-configuration-security-baseline#im-8-restrict-the-exposure-of-credential-and-secrets)
- [Use Key Vault references in an ASP.NET Core app](https://learn.microsoft.com/azure/azure-app-configuration/use-key-vault-references-dotnet-core)
- [Reload secrets and certificates from Key Vault automatically](https://learn.microsoft.com/azure/azure-app-configuration/reload-key-vault-secrets-dotnet)
- [Use Azure App Configuration in Azure Container Apps](https://learn.microsoft.comazure/azure-app-configuration/quickstart-container-apps)
- [Use App Configuration references for Azure App Service and Azure Functions](https://learn.microsoft.com/azure/app-service/app-service-configuration-references)
- [Use Azure App Configuration in Azure Kubernetes Service](https://learn.microsoft.com/azure/azure-app-configuration/quickstart-azure-kubernetes-service)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)

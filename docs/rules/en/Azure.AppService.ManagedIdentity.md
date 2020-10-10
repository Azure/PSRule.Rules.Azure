---
severity: Important
pillar: Security
category: Identity and access management
resource: App Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppService.ManagedIdentity.md
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

## LINKS

- [What are managed identities for Azure resources?](https://docs.microsoft.comazure/active-directory/managed-identities-azure-resources/overview)
- [Tutorial: Secure Azure SQL Database connection from App Service using a managed identity](https://docs.microsoft.com/azure/app-service/app-service-web-tutorial-connect-msi)
- [How to use managed identities for App Service and Azure Functions](https://docs.microsoft.com/azure/app-service/overview-managed-identity?tabs=dotnet)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#managedserviceidentity-object)

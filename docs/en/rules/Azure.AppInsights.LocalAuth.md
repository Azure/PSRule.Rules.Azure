---
reviewed: 2025-05-25
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Application Insights
resourceType: Microsoft.Insights/components
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppInsights.LocalAuth/
---

# Application Insights local authentication is enabled

## SYNOPSIS

Local authentication allows depersonalized access to store telemetry in Application Insights using a shared identifier.

## DESCRIPTION

Application Insights (App Insights) includes a built-in local authentication account.
The local authentication account is a single non-changeable identifier called an _Instrumentation Key_.
This key allows depersonalized access to send telemetry data to an App Insights resource.

Instead of using the admin account, consider using Entra ID (previously Azure AD) identities.
Entra ID provides a centralized identity and authentication system for Azure.
This provides a number of benefits including:

- Strong account protection controls with conditional access, identity governance, and privileged identity management.
- Auditing and reporting of account activity.
- Granular access control with role-based access control (RBAC).
- Separation of account types for users and applications.

## RECOMMENDATION

Consider disabling local authentication and only use identity-based authentication for telemetry operations.

## EXAMPLES

### Configure with Bicep

To deploy resource that pass this rule:

- Set the `properties.DisableLocalAuth` property to `true`.

For example:

```bicep
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    WorkspaceResourceId: workspaceId
    DisableLocalAuth: true
  }
}
```

### Configure with Azure template

To deploy resource that pass this rule:

- Set the `properties.DisableLocalAuth` property to `true`.

For example:

```json
{
  "type": "Microsoft.Insights/components",
  "apiVersion": "2020-02-02",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "kind": "web",
  "properties": {
    "Application_Type": "web",
    "Flow_Type": "Redfield",
    "Request_Source": "IbizaAIExtension",
    "WorkspaceResourceId": "[parameters('workspaceId')]",
    "DisableLocalAuth": true
  }
}
```

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Microsoft Entra authentication for Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/azure-ad-authentication)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/components)

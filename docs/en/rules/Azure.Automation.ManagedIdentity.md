---
reviewed: 2022-05-14
severity: Important
pillar: Security
category: Authentication
resource: Automation Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Automation.ManagedIdentity/
---

# Use managed identity for authentication

## SYNOPSIS

Ensure Managed Identity is used for authentication.

## DESCRIPTION

Azure automation can use Managed Identities to authenticate to Azure resources without storing credentials.

Using managed identities have the following benefits:

- Using a managed identity instead of the Automation Run As account simplifies management.
  You don't have to renew the certificate used by a Run As account.
- Managed Identities can be used without any additional cost.
- You don't have to specify the Run As connection object in your runbook code.
  You can access resources using your Automation Account's Managed Identity from a runbook.

## RECOMMENDATION

Consider configure a managed identity for each Automation Account.

## EXAMPLES

### Configure with Azure template

To deploy Automation Accounts that pass this rule:

- Set `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```json
{
    "type": "Microsoft.Automation/automationAccounts",
    "apiVersion": "2021-06-22",
    "name": "[parameters('automation_account_name')]",
    "location": "australiaeast",
    "identity": {
        "type": "SystemAssigned"
    },
    "properties": {
        "disableLocalAuth": false,
        "sku": {
            "name": "Basic"
        },
        "encryption": {
            "keySource": "Microsoft.Automation",
            "identity": {}
        }
    }
}
```

### Configure with Bicep

To deploy Automation Accounts that pass this rule:

- Set `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource automation_account_name_resource 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automation_account_name
  location: 'australiaeast'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: false
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
      identity: {}
    }
  }
}
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [Managed identities](https://docs.microsoft.com/azure/automation/automation-security-overview#managed-identities)
- [Using a system-assigned managed identity for an Azure Automation account](https://docs.microsoft.com/azure/automation/enable-managed-identity-for-automation)
- [Using a user-assigned managed identity for an Azure Automation account](https://docs.microsoft.com/azure/automation/add-user-assigned-identity)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.automation/automationaccounts#identity)

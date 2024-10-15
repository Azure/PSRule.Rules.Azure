---
reviewed: 2024-10-14
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.AdminUser/
ms-content-id: bbf194a7-6ca3-4b1d-9170-6217eb26620d
---

# Container Registry local admin account is enabled

## SYNOPSIS

The local admin account allows depersonalized access to a container registry using a shared secret.

## DESCRIPTION

Azure Container Registry (ACR) includes a built-in local admin user account.
The local admin account is a single user account with administrative access to the registry.
This account is intended for early proof of concepts and working with sample code.
The admin user account is not intended for general use with container registries.

Instead of using the admin account, consider using Entra ID (previously Azure AD) identities.
Entra ID provides a centralized identity and authentication system for Azure.
This provides a number of benefits including:

- Strong account protection controls with conditional access, identity governance, and privileged identity management.
- Auditing and reporting of account activity.
- Granular access control with role-based access control (RBAC).
- Separation of account types for users and applications.

## RECOMMENDATION

Consider disabling the local admin account and only use identity-based authentication for registry operations.

## EXAMPLES

### Configure with Azure template

To deploy registries that pass this rule:

- Set `properties.adminUserEnabled` to `false`.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2023-07-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "adminUserEnabled": false,
    "policies": {
      "trustPolicy": {
        "status": "enabled",
        "type": "Notary"
      },
      "retentionPolicy": {
        "days": 30,
        "status": "enabled"
      }
    }
  }
}
```

### Configure with Bicep

To deploy registries that pass this rule:

- Set `properties.adminUserEnabled` to `false`.

For example:

```bicep
resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    policies: {
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
    }
  }
}
```

<!-- external:avm avm/res/container-registry/registry:0.5.1 acrAdminUserEnabled -->

### Configure with Azure CLI

To configure registries that pass this rule:

```bash
az acr update -n '<name>' -g '<resource_group>' --admin-enabled false
```

### Configure with Azure PowerShell

To configure registries that pass this rule:

```powershell
Update-AzContainerRegistry -ResourceGroupName '<resource_group>' -Name '<name>' -DisableAdminUser
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Container registries should have local admin account disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Container%20Registry/ACR_AdminAccountDisabled_AuditDeny.json)
  `/providers/Microsoft.Authorization/policyDefinitions/dc921057-6b28-4fbe-9b83-f7bec05db6c2`.
- [Configure container registries to disable local admin account](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Container%20Registry/ACR_AdminAccountDisabled_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/79fdfe03-ffcb-4e55-b4d0-b925b8241759`.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Authenticate with a private Docker container registry](https://learn.microsoft.com/azure/container-registry/container-registry-authentication)
- [Best practices for Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-best-practices#authentication-and-authorization)
- [Use an Azure managed identity to authenticate to an Azure container registry](https://learn.microsoft.com/azure/container-registry/container-registry-authentication-managed-identity)
- [Azure Container Registry roles and permissions](https://learn.microsoft.com/azure/container-registry/container-registry-roles)
- [What is Azure role-based access control (Azure RBAC)?](https://learn.microsoft.com/azure/role-based-access-control/overview)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [IM-3: Manage application identities securely and automatically](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#im-3-manage-application-identities-securely-and-automatically)
- [PA-1: Separate and limit highly privileged/administrative users](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#pa-1-separate-and-limit-highly-privilegedadministrative-users)
- [Azure Policy Regulatory Compliance controls for Azure Container Registry](https://learn.microsoft.com/azure/container-registry/security-controls-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)

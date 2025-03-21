---
severity: Important
pillar: Security
category: SE:12 Incident response
resource: Microsoft Defender for Cloud
resourceType: Microsoft.Security/securityContacts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Defender.SecurityContact/
ms-content-id: 18fcf75f-a5e6-4a34-baba-74bd49502cd7
---

# Defender for Cloud notification contact not set

## SYNOPSIS

Important security notifications may be lost or not processed in a timely manner when a clear security contact is not identified.

## DESCRIPTION

Microsoft Defender for Cloud allows one or more email addresses to be specified for receiving security alerts.
This is in addition to subscription owners or other configured role.

Directing security notifications to the correct party enables triage and response to security incidents in a timely manner.

## RECOMMENDATION

Consider configuring a security notification email address to assist timely notification and incident response.

## EXAMPLES

### Configure with Azure template

To deploy subscriptions that pass this rule:

- Set the `properties.emails` property to an email address for security incident response.

For example:

```json
{
  "type": "Microsoft.Security/securityContacts",
  "apiVersion": "2023-12-01-preview",
  "name": "default",
  "properties": {
    "isEnabled": true,
    "notificationsByRole": {
      "roles": [
        "Owner"
      ],
      "state": "On"
    },
    "emails": "security@contoso.com",
    "notificationsSources": [
      {
        "sourceType": "Alert",
        "minimalSeverity": "High"
      },
      {
        "sourceType": "AttackPath",
        "minimalRiskLevel": "High"
      }
    ]
  }
}
```

### Configure with Bicep

To deploy subscriptions that pass this rule:

- Set the `properties.emails` property to an email address for security incident response.

For example:

```bicep
resource securityContact 'Microsoft.Security/securityContacts@2023-12-01-preview' = {
  name: 'default'
  properties: {
    isEnabled: true
    notificationsByRole: {
      roles: [
        'Owner'
      ]
      state: 'On'
    }
    emails: 'security@contoso.com'
    notificationsSources: [
      {
        sourceType: 'Alert'
        minimalSeverity: 'High'
      }
      {
        sourceType: 'AttackPath'
        minimalRiskLevel: 'High'
      }
    ]
  }
}
```

### Configure with Azure CLI

```bash
az security contact update -n 'default' --emails 'security@contoso.com'
```

## LINKS

- [SE:12 Incident response](https://learn.microsoft.com/azure/well-architected/security/incident-response)
- [Quickstart: Configure email notifications for security alerts](https://learn.microsoft.com/azure/defender-for-cloud/configure-email-notifications)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/securitycontacts)

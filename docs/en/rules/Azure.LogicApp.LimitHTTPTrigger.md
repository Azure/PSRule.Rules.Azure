---
reviewed: 2025-01-17
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Logic App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LogicApp.LimitHTTPTrigger/
---

# Logic App HTTP request trigger is not restricted

## SYNOPSIS

Logic Apps using HTTP triggers without restrictions can be accessed from any network location including the Internet.

## DESCRIPTION

Logic Apps are workflows that integrate services and systems across cloud services and on-premises systems.
Logic Apps can be triggered by a variety of events including HTTP requests.

When HTTP request trigger is configured,
by default the Logic App in a consumption plan may receive requests from any source IP address.
This can expose the Logic App to unauthorized access or exfiltration attempts.

Logic Apps can be secured by restricting access to trusted IP addresses.

## RECOMMENDATION

Consider restricting HTTP triggers to trusted IP addresses to harden against unauthorized access or exfiltration attempts.

## EXAMPLES

### Configure with Azure template

To deploy Logic Apps that pass this rule:

- Set the `allowedCallerIpAddresses` property to a list of IP address ranges.

For example:

```json
{
  "type": "Microsoft.Logic/workflows",
  "apiVersion": "2019-05-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "definition": "<workflow-definition>",
    "parameters": {},
    "accessControl": {
      "contents": {
        "allowedCallerIpAddresses": [
          {
            "addressRange": "192.168.12.0/23"
          },
          {
            "addressRange": "2001:0db8::/64"
          }
        ]
      }
    }
  }
}
```

### Configure with Bicep

To deploy Logic Apps that pass this rule:

- Set the `allowedCallerIpAddresses` property to a list of IP address ranges.

For example:

```bicep
resource app 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  properties: {
    definition: '<workflow-definition>'
    parameters: {}
    accessControl: {
      contents: {
        allowedCallerIpAddresses: [
          {
            addressRange: '192.168.12.0/23'
          }
          {
            addressRange: '2001:0db8::/64'
          }
        ]
      }
    }
  }
}
```

## NOTES

This rule currently only applies to Logic Apps using consumption plans.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Secure access and data in Azure Logic Apps](https://learn.microsoft.com/azure/logic-apps/logic-apps-securing-a-logic-app)
- [Azure security baseline for Logic Apps](https://learn.microsoft.com/azure/logic-apps/security-baseline#network-security)

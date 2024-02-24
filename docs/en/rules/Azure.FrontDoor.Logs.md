---
reviewed: 2024-02-24
severity: Important
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.Logs/
---

# Audit Front Door Access

## SYNOPSIS

Audit and monitor access through Azure Front Door profiles.

## DESCRIPTION

Azure Front Door (AFD) supports logging network access to resources through the service.
This includes access logs and web application firewall logs.
Capturing these logs can help detect and respond to security threats as part of a security monitoring strategy.
Additionally, many compliance standards require logging and monitoring of network access.

Like all security monitoring, it is only effective if the logs are reviewed and correlated with other security events.
Microsoft Sentinel can be used to analyze and correlate logs, or third-party solutions can be used.

To capture network access events through Front Door, diagnostic settings must be configured.
When configuring diagnostics settings enable collection of the following logs:

- `FrontdoorAccessLog` - Can be used to monitor network activity and access through Front Door.
- `FrontdoorWebApplicationFirewallLog` - Can be used to detect potential attacks, or false positive detections.
  This log will be empty if a WAF policy is not configured.

Management operations for Front Door is captured automatically within Azure Activity Logs.

## RECOMMENDATION

Consider configuring diagnostics setting to log network activity and access through Azure Front Door (AFD).
Also consider correlating logs with other security events to detect and respond to security threats.

## EXAMPLES

### Configure with Azure template

To deploy Azure Front Door Premium/ Standard profiles that passes this rule:

- Deploy a diagnostic settings sub-resource.
  - Enable logging for the `FrontdoorAccessLog` category.
  - Enable logging for the `FrontdoorWebApplicationFirewallLog` category if a WAF policy is configured.

For example:

```json
{
  "type": "Microsoft.Insights/diagnosticSettings",
  "apiVersion": "2021-05-01-preview",
  "scope": "[format('Microsoft.Cdn/profiles/{0}', parameters('name'))]",
  "name": "audit",
  "properties": {
    "workspaceId": "[parameters('workspaceId')]",
    "logs": [
      {
        "category": "FrontdoorAccessLog",
        "enabled": true
      },
      {
        "category": "FrontdoorWebApplicationFirewallLog",
        "enabled": true
      }
    ]
  },
  "dependsOn": [
    "[resourceId('Microsoft.Cdn/profiles', parameters('name'))]"
  ]
}
```

To deploy Azure Front Door Classic profiles that passes this rule:

- Deploy a diagnostic settings sub-resource.
  - Enable logging for the `FrontdoorAccessLog` category.
  - Enable logging for the `FrontdoorWebApplicationFirewallLog` category if a WAF policy is configured.

For example:

```json
{
  "type": "Microsoft.Insights/diagnosticSettings",
  "apiVersion": "2021-05-01-preview",
  "scope": "[format('Microsoft.Network/frontDoors/{0}', parameters('name'))]",
  "name": "audit",
  "properties": {
    "workspaceId": "[parameters('workspaceId')]",
    "logs": [
      {
        "category": "FrontdoorAccessLog",
        "enabled": true
      },
      {
        "category": "FrontdoorWebApplicationFirewallLog",
        "enabled": true
      }
    ]
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/frontDoors', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy Azure Front Door Premium/ Standard profiles that passes this rule:

- Deploy a diagnostic settings sub-resource.
  - Enable logging for the `FrontdoorAccessLog` category.
  - Enable logging for the `FrontdoorWebApplicationFirewallLog` category.

For example:

```bicep
resource audit 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'audit'
  scope: afd_profile
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'FrontdoorAccessLog'
        enabled: true
      }
      {
        category: 'FrontdoorWebApplicationFirewallLog'
        enabled: true
      }
    ]
  }
}
```

To deploy Azure Front Door Classic profiles that passes this rule:

- Deploy a diagnostic settings sub-resource.
  - Enable logging for the `FrontdoorAccessLog` category.
  - Enable logging for the `FrontdoorWebApplicationFirewallLog` category.

For example:

```bicep
resource audit_classic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'audit'
  scope: afd_classic
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'FrontdoorAccessLog'
        enabled: true
      }
      {
        category: 'FrontdoorWebApplicationFirewallLog'
        enabled: true
      }
    ]
  }
}
```

## NOTES

This rule applies to Azure Front Door Premium/ Standard/ Classic profiles.

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [LT-4: Enable logging for security investigation](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-front-door-security-baseline#lt-4-enable-logging-for-security-investigation)
- [Monitor metrics and logs in Azure Front Door](https://learn.microsoft.com/azure/frontdoor/front-door-diagnostics?pivots=front-door-standard-premium)
- [Monitor metrics and logs in Azure Front Door Classic](https://learn.microsoft.com/azure/frontdoor/front-door-diagnostics?pivots=front-door-classic)
- [What is Microsoft Sentinel?](https://learn.microsoft.com/azure/sentinel/overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)

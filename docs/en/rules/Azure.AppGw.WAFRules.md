---
severity: Important
pillar: Security
category: Network security and containment
resource: Application Gateway
resourceType: Microsoft.Network/applicationGateways
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.WAFRules/
---

# Application Gateway rules are enabled

## SYNOPSIS

Application Gateway Web Application Firewall (WAF) should have all rules enabled.

## DESCRIPTION

Application Gateway instances with WAF allow OWASP detection/ prevention rules to be toggled on or off.
All OWASP rules are turned on by default.

When OWASP rules are turned off, the protection they provide is disabled.

## RECOMMENDATION

Consider enabling all OWASP rules within Application Gateway instances.

Before disabling OWASP rules, ensure that the backend workload has alternative protections in-place.
Alternatively consider updating application code to use safe web standards.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set the `properties.webApplicationFirewallConfiguration.disabledRuleGroups.ruleGroupName` property to `$ruleName`.

For example:

```json
{
    "type": "Microsoft.Network/applicationGateways",
    "apiVersion": "2020-11-01",
    "name": "appGw-001",
    "location": "[resourceGroup().location]",
    "properties": {
        "sku": {
            "name": "WAF_v2",
            "tier": "WAF_v2"
        },
        "webApplicationFirewallConfiguration": {
            "enabled": true,
            "firewallMode": "Prevention",
            "ruleSetType": "OWASP",
            "ruleSetVersion": "3.2",
            "disabledRuleGroups": [
              {
                "ruleGroupName": "exampleRule",
                "rules": []
              }
            ],
            "requestBodyCheck": true,
            "maxRequestBodySizeInKb": 128,
            "fileUploadLimitInMb": 100
        }
    }
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Set the `properties.webApplicationFirewallConfiguration.enabled` property to `true`.

For example:

```bicep
resource appGw 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: 'appGw-001'
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
      disabledRuleGroups: [
        {
          ruleGroupName: 'exampleRule',
          rules: []
        }
      ]
    }
  }
}
```

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview)
- [Web Application Firewall CRS rule groups and rules](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)

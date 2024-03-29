---
severity: Important
pillar: Security
category: Network security and containment
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.OWASP/
---

# Use OWASP 3.x rules

## SYNOPSIS

Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules.

## DESCRIPTION

Application Gateways deployed with WAF features support configuration of OWASP rule sets for detection and /
or prevention of malicious attacks. Two rule set versions are available; OWASP 2.x and OWASP 3.x.

## RECOMMENDATION

Consider configuring Application Gateways to use OWASP 3.x rules instead of 2.x rule set versions.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set the `properties.webApplicationFirewallConfiguration.ruleSetType` property to `OWASP`.
- Set the `properties.webApplicationFirewallConfiguration.ruleSetVersion` property to a minimum of `3.2`.

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
            "disabledRuleGroups": [],
            "requestBodyCheck": true,
            "maxRequestBodySizeInKb": 128,
            "fileUploadLimitInMb": 100
        }
    }
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Set the `properties.webApplicationFirewallConfiguration.ruleSetType` property to `OWASP`.
- Set the `properties.webApplicationFirewallConfiguration.ruleSetVersion` property to a minimum of `3.2`.

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
    }
  }
}
```

### Configure with Azure CLI

```bash
az network application-gateway waf-config set --enabled true --rule-set-type OWASP --rule-set-version '3.2' -n '<name>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
$AppGw = Get-AzApplicationGateway -Name '<name>' -ResourceGroupName '<resource_group>'
Set-AzApplicationGatewayWebApplicationFirewallConfiguration -ApplicationGateway $AppGw -Enabled $True -FirewallMode 'Prevention' -RuleSetType 'OWASP' -RuleSetVersion '3.2'
```

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [OWASP ModSecurity Core Rule Set](https://owasp.org/www-project-modsecurity-core-rule-set/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)

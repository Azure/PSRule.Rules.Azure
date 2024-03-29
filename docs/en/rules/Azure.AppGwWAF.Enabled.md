---
reviewed: 2022-09-20
severity: Critical
pillar: Security
category: Network security and containment
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGwWAF.Enabled/
---

# Application Gateway WAF is enabled

## SYNOPSIS

Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources.

## DESCRIPTION

Security features of Application Gateways deployed with WAF may be toggled on or off.

When WAF is disabled network traffic is still processed by the Application Gateway however detection
and/ or prevention of malicious attacks does not occur.

To protect backend resources from potentially malicious network traffic, WAF must be enabled.

## RECOMMENDATION

Consider enabling WAF for Application Gateway instances connected to un-trusted or low-trust networks such as the Internet.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set the `properties.policySettings.state` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies",
  "apiVersion": "2022-01-01",
  "name": "agwwaf",
  "location": "[parameters('location')]",
  "properties": {
    "managedRules": {
      "managedRuleSets": [
        {
          "ruleSetType": "OWASP",
          "ruleSetVersion": "3.2"
        },
        {
          "ruleSetType": "Microsoft_BotManagerRuleSet",
          "ruleSetVersion": "0.1"
        }
      ]
    },
    "policySettings": {
      "state": "Enabled",
      "mode": "Prevention"
    }
  }
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Set the `properties.policySettings.state` property to `Enabled`.

For example:

```bicep
resource waf 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-01-01' = {
  name: 'agwwaf'
  location: location
  properties: {
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '0.1'
        }
      ]
    }
    policySettings: {
      state: 'Enabled'
      mode: 'Prevention'
    }
  }
}
```

### Configure with Azure CLI

```bash
az network application-gateway waf-config set --enabled true -n '<name>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
$AppGw = Get-AzApplicationGateway -Name '<name>' -ResourceGroupName '<resource_group>'
Set-AzApplicationGatewayWebApplicationFirewallConfiguration -ApplicationGateway $AppGw -Enabled $True -FirewallMode 'Prevention'
```

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)
- [Web Application Firewall best practices](https://learn.microsoft.com/azure/web-application-firewall/ag/best-practices)

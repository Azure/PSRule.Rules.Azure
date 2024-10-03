---
reviewed: 2021-07-25
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.UseWAF/
---

# Application Gateway uses WAF SKU

## SYNOPSIS

Internet accessible Application Gateways should use protect endpoints with WAF.

## DESCRIPTION

Application Gateway endpoints can optionally be configured with a Web Application Firewall (WAF) policy.
When configured, every incoming request is filtered by the WAF policy.

To use a WAF policy, the Application Gateway must be deployed with a Web Application Firewall SKU.

## RECOMMENDATION

Consider deploying Application Gateways with a WAF SKU to protect against common attacks.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Deploy an Application Gateway with the `WAF` or `WAF_v2` SKU.

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

- Deploy an Application Gateway with the `WAF` or `WAF_v2` SKU.

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
az network application-gateway update --sku WAF_v2 -n '<name>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
$AppGw = Get-AzApplicationGateway -Name '<name>' -ResourceGroupName '<resource_group>'
$AppGw = Set-AzApplicationGatewaySku -ApplicationGateway $AppGw -Name 'WAF_v2' -Tier 'WAF_v2'
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)

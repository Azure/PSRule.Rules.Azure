---
severity: Critical
pillar: Security
category: Network security and containment
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.Prevention/
author: BernieWhite
ms-date: 2021/07/25
---

# Use WAF prevention mode

## SYNOPSIS

Internet exposed Application Gateways should use prevention mode to protect backend resources.

## DESCRIPTION

Application Gateways with Web Application Firewall (WAF) enabled support two modes of operation:

- **Detection** - Monitors and logs all threat alerts.
  In this mode, the WAF doesn't block incoming requests that are potentially malicious.
- **Protection** - Blocks potentially malicious attack patterns that the rules detect.

## RECOMMENDATION

Consider switching Internet exposed Application Gateways to use prevention mode to protect backend resources.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Set the `properties.webApplicationFirewallConfiguration.firewallMode` property to `Prevention`.

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

- Set the `properties.webApplicationFirewallConfiguration.firewallMode` property to `Prevention`.

For example:

```bicep
resource name_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
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
      disabledRuleGroups: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
  }
}
```

### Configure with Azure CLI

```bash
az network application-gateway waf-config set --enabled true --firewall-mode Prevention -n '<name>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
$AppGw = Get-AzApplicationGateway -Name '<name>' -ResourceGroupName '<resource_group>'
Set-AzApplicationGatewayWebApplicationFirewallConfiguration -ApplicationGateway $AppGw -Enabled $True -FirewallMode 'Prevention'
```

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Application Gateway WAF modes](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview#waf-modes)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)

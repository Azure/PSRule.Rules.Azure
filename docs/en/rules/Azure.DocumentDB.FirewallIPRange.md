---
reviewed: 2026-11-23
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters,Microsoft.DocumentDB/mongoClusters/firewallRules
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.FirewallIPRange/
---

# Limit IP addresses permitted by Azure DocumentDB firewall rules

## SYNOPSIS

Azure DocumentDB firewall rules should limit the number of permitted IP addresses.

## DESCRIPTION

Broad firewall ranges increase the number of hosts that can attempt to connect to a cluster.
This rule recommends limiting the sum of the inclusive address counts across firewall rules to 10.
When evaluating an individual firewall child resource, the same limit applies to that resource.
The limit is a best-practice recommendation, not an Azure service limit.

## RECOMMENDATION

Consider using private endpoints, or tightly scoped firewall exceptions for required application egress addresses.

## EXAMPLES

### Configure with Azure template

The following range includes exactly 10 addresses and passes when no other address ranges are configured.
Replace the documentation addresses with your application's egress addresses.

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters/firewallRules",
  "apiVersion": "2026-06-01",
  "name": "[format('{0}/allow-client', parameters('clusterName'))]",
  "properties": {
    "startIpAddress": "203.0.113.1",
    "endIpAddress": "203.0.113.10"
  }
}
```

### Configure with Bicep

```bicep
param clusterName string

resource cluster 'Microsoft.DocumentDB/mongoClusters@2026-06-01' existing = {
  name: clusterName
}

resource firewall 'Microsoft.DocumentDB/mongoClusters/firewallRules@2026-06-01' = {
  name: 'allow-client'
  parent: cluster
  properties: {
    startIpAddress: '203.0.113.1'
    endIpAddress: '203.0.113.10'
  }
}
```

## NOTES

Provide the complete firewall rule set when evaluating a cluster.
Overlapping ranges are counted separately to encourage removing redundant rules.
The `0.0.0.0` to `0.0.0.0` Azure-services sentinel is excluded from the count and checked by
[Azure.DocumentDB.AllowAzureAccess](Azure.DocumentDB.AllowAzureAccess.md).
The internet-wide `0.0.0.0` to `255.255.255.255` range fails this rule.
Rules are checked even if the cluster's public endpoint is disabled.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Manage public access](https://learn.microsoft.com/azure/documentdb/how-to-public-access)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters/firewallrules)

---
reviewed: 2026-11-23
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.FirewallRuleCount/
---

# Limit Azure DocumentDB firewall rules

## SYNOPSIS

Azure DocumentDB clusters should limit the number of firewall rules.

## DESCRIPTION

Large firewall rule sets are harder to review and maintain.
This rule recommends no more than 10 firewall rules per cluster, consistent with the database firewall guidance used by PSRule for Azure.
This is a best-practice threshold, not an Azure service limit.
Prefer private connectivity and remove firewall rules that are no longer required.

## RECOMMENDATION

Consider keeping no more than 10 cluster-level firewall rules.

## EXAMPLES

### Configure with Azure template

For a cluster that requires a public-access exception, use narrowly scoped rules.
The following child resource permits one address.
Ensure the cluster's complete firewall rule set contains no more than 10 rules.

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters/firewallRules",
  "apiVersion": "2026-06-01",
  "name": "[format('{0}/allow-client', parameters('clusterName'))]",
  "properties": {
    "startIpAddress": "203.0.113.1",
    "endIpAddress": "203.0.113.1"
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
    endIpAddress: '203.0.113.1'
  }
}
```

## NOTES

This rule counts firewall child resources associated with a cluster.
Provide the complete resource export or expanded deployment, including firewall resources.
Clusters without firewall rules pass.
The check also reports excessive rules when public access is disabled, so unsafe or stale configuration can be removed.
The documentation address `203.0.113.1` must be replaced with your application's actual egress address.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Manage public access](https://learn.microsoft.com/azure/documentdb/how-to-public-access)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters/firewallrules)

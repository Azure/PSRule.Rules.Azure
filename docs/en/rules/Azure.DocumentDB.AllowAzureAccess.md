---
reviewed: 2026-11-23
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters,Microsoft.DocumentDB/mongoClusters/firewallRules
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.AllowAzureAccess/
---

# Restrict Azure-wide access to Azure DocumentDB clusters

## SYNOPSIS

Azure DocumentDB clusters should not allow access from all Azure services.

## DESCRIPTION

Allowing connections from all Azure services also allows connection attempts from resources in other customers' subscriptions.
Authentication is still required, but the network boundary is much broader than the applications that need access.
Use private endpoints or specific application egress addresses instead.

## RECOMMENDATION

Consider removing the firewall rule whose start and end addresses are both `0.0.0.0`.

## EXAMPLES

### Configure with Azure template

Remove the Azure-services rule and retain only required client addresses, such as this restricted exception.
Replace the documentation address with your application's egress address.

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

This rule evaluates cluster-level child resources and individually supplied firewall resources, regardless of the firewall rule's name.
An incremental ARM deployment does not delete omitted resources.
Explicitly delete the existing Azure-services firewall rule, or use an appropriate deployment lifecycle mechanism.
The internet-wide range is covered separately by [Azure.DocumentDB.FirewallIPRange](Azure.DocumentDB.FirewallIPRange.md).
This rule does not evaluate the separate `networkBypassMode` setting.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Manage public access](https://learn.microsoft.com/azure/documentdb/how-to-public-access)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters/firewallrules)

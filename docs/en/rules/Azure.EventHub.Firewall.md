---
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Event Hub
resourceType: Microsoft.EventHub/namespaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventHub.Firewall/
---

# Access to the namespace endpoints should be restricted to only allowed sources

## SYNOPSIS

Access to the namespace endpoints should be restricted to only allowed sources.

## DESCRIPTION

By default, Event Hub namespaces are accessible from public internet.

With the firewall feature, it is possible to either fully disabling public network access by ensuring that the namespace endpoints isn't exposed on the public internet or configure rules to only accept traffic from specific addresses.

## RECOMMENDATION

Consider restricting network access to the Event Hub namespace by requiring private endpoints or by limiting access to permitted client addresses with the service firewall.

## EXAMPLES

### Configure with Azure template

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled` to require private endpoints. OR
- Alternatively, you can configure the `Microsoft.EventHub/namespaces/networkRuleSets` sub-resource by:
  - Setting the `properties.publicNetworkAccess` property to `Disabled` to require private endpoints. OR
  - Setting the `properties.defaultAction` property to `Deny` to restrict network access to the service by default.

For example:

```json
{
  "type": "Microsoft.EventHub/namespaces",
  "apiVersion": "2024-01-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "sku": {
    "name": "Standard"
  },
  "properties": {
    "disableLocalAuth": true,
    "minimumTlsVersion": "1.2",
    "publicNetworkAccess": "Disabled",
    "zoneRedundant": true
  }
}
```

### Configure with Bicep

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled` to require private endpoints. OR
- Alternatively, you can configure the `Microsoft.EventHub/namespaces/networkRuleSets` sub-resource by:
  - Setting the `properties.publicNetworkAccess` property to `Disabled` to require private endpoints. OR
  - Setting the `properties.defaultAction` property to `Deny` to restrict network access to the service by default.

For example:

```bicep
resource ns 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}
```

## NOTES

If there are no IP and virtual network rules, all the traffic flows into the namespace even if you set the defaultAction to `deny` on the firewall. The namespace can be accessed over the public internet. Specify at least one IP rule or virtual network rule for the namespace to activate the default action on the firewall.

The firewall feature isn't supported in the `basic` tier.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Azure security baseline for Event Hub](https://learn.microsoft.com/security/benchmark/azure/baselines/event-hubs-security-baseline)
- [NS-1: Establish network segmentation boundaries](https://learn.microsoft.com/security/benchmark/azure/baselines/event-hubs-security-baseline#ns-1-establish-network-segmentation-boundaries)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/event-hubs-security-baseline#ns-1-establish-network-segmentation-boundaries)
- [Allow access to Azure Event Hub namespaces from specific IP addresses or ranges](https://learn.microsoft.com/azure/event-hubs/event-hubs-ip-filtering)
- [Allow access to Azure Event Hub namespaces from specific virtual networks](https://learn.microsoft.com/azure/event-hubs/event-hubs-service-endpoints)
- [Allow access to Azure Event Hub namespaces via private endpoints](https://learn.microsoft.com/azure/event-hubs/private-link-service)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces/eventhubs)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces/networkrulesets)

---
reviewed: 2026-11-24
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Traffic Manager
resourceType: Microsoft.Network/trafficManagerProfiles
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.TrafficManager.Endpoints/
---

# Use at least two Traffic Manager endpoints

## SYNOPSIS

Traffic Manager should use at least two enabled endpoints.

## DESCRIPTION

Traffic Manager is a DNS service that enables you to distribute traffic to improve availability and responsiveness.
Traffic is distributed across endpoints, which can be located in different availability zones and regions.

When only one enabled endpoint exists, routing for high availability and/or responsiveness is not possible.

## RECOMMENDATION

Consider adding additional endpoints or enabling disabled endpoints.
Also consider using endpoints deployed across different regions to provide high availability.

## EXAMPLES

### Configure with Azure template

To deploy Traffic Manager profiles that pass this rule:

- Configure at least two endpoints in the `properties.endpoints` property.
- Set the `properties.endpoints[*].properties.endpointStatus` property to `Enabled` for at least two endpoints.

For example:

```json
{
  "type": "Microsoft.Network/trafficmanagerprofiles",
  "apiVersion": "2022-04-01",
  "name": "[parameters('name')]",
  "location": "global",
  "properties": {
    "trafficRoutingMethod": "Performance",
    "dnsConfig": {
      "relativeName": "[parameters('name')]",
      "ttl": 60
    },
    "monitorConfig": {
      "protocol": "HTTPS",
      "port": 443,
      "path": "/healthz"
    },
    "endpoints": [
      {
        "name": "endpoint-a",
        "type": "Microsoft.Network/trafficManagerProfiles/externalEndpoints",
        "properties": {
          "target": "app-a.contoso.com",
          "endpointStatus": "Enabled",
          "endpointLocation": "East US"
        }
      },
      {
        "name": "endpoint-b",
        "type": "Microsoft.Network/trafficManagerProfiles/externalEndpoints",
        "properties": {
          "target": "app-b.contoso.com",
          "endpointStatus": "Enabled",
          "endpointLocation": "West Europe"
        }
      }
    ]
  }
}
```

### Configure with Bicep

To deploy Traffic Manager profiles that pass this rule:

- Configure at least two endpoints in the `properties.endpoints` property.
- Set the `properties.endpoints[*].properties.endpointStatus` property to `Enabled` for at least two endpoints.

For example:

```bicep
resource profile 'Microsoft.Network/trafficmanagerprofiles@2022-04-01' = {
  name: name
  location: 'global'
  properties: {
    trafficRoutingMethod: 'Performance'
    dnsConfig: {
      relativeName: name
      ttl: 60
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/healthz'
    }
    endpoints: [
      {
        name: 'endpoint-a'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          target: 'app-a.contoso.com'
          endpointStatus: 'Enabled'
          endpointLocation: 'East US'
        }
      }
      {
        name: 'endpoint-b'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          target: 'app-b.contoso.com'
          endpointStatus: 'Enabled'
          endpointLocation: 'West Europe'
        }
      }
    ]
  }
}
```

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [What is Traffic Manager?](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-overview)
- [How Traffic Manager Works](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-how-it-works)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/trafficmanagerprofiles)

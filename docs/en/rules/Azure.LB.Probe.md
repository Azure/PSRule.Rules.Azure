---
reviewed: 2024-04-11
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Load Balancer
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LB.Probe/
---

# Use a specific load balancer probe

## SYNOPSIS

Use a specific probe for web protocols.

## DESCRIPTION

A load balancer is an Azure service that distributes traffic among instances of a service in a backend pool (such as VMs).
Load balancers route traffic to instances in the backend pool based on configured rules.

In additional to routing traffic, load balancers can also monitor the health of backend instances with a health probe.
Monitoring the health of backend instances allows the load balancer to route traffic towards health instances.
For example, if one instance is unavailable, the load balancer can route traffic to another instance that is available.

To monitor the health of backend instances, the load balancer sends periodic requests and checks the response from the backend.
Azure Load Balancer supports health probes for TCP, HTTP, and HTTPS.

If your backend is communicating over HTTP or HTTPS, you should:

- Use HTTP/ HTTPS probes &mdash; instead of a TCP port.
  For example, if a web server process is running it may not be able to respond to a TCP probe.
  However, that does not indicate that the application is working correctly, as it could be returning a `5XX` error.
  Using HTTP/ HTTPS probes allows you to check for a HTTP 200 status code.
- Use a dedicated health check endpoint &mdash; such as `/health`  or `/healthz` for health probes.
  Commonly the main landing page of an application `/` is not a good health check endpoint.
  By design, it may only serve static content and not execute any application logic, such as a login page.

## RECOMMENDATION

Consider using a dedicated health check endpoint for HTTP or HTTPS health probes.

## EXAMPLES

### Configure with Azure template

To deploy load balancers that pass this rule:

- Configure HTTP or HTTPS based probes on ports that commonly use HTTP or HTTPS protocols.
  - Set the `properties.probes[*]` property to include a probe with the following properties:
    - `properties.probes[*].properties.protocol` set to `HTTPS`.
    - `properties.probes[*].properties.requestPath` set to `/health`.

For example:

```json
{
  "type": "Microsoft.Network/loadBalancers",
  "apiVersion": "2023-09-01",
  "name": "[parameters('lbName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard"
  },
  "properties": {
    "frontendIPConfigurations": [
      {
        "name": "frontend1",
        "properties": {
          "privateIPAddressVersion": "IPv4",
          "privateIPAllocationMethod": "Dynamic",
          "subnet": {
            "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('name'), 'GatewaySubnet')]"
          }
        },
        "zones": [
          "2",
          "3",
          "1"
        ]
      }
    ],
    "backendAddressPools": [
      {
        "name": "backend1"
      }
    ],
    "probes": [
      {
        "name": "https",
        "properties": {
          "protocol": "HTTPS",
          "port": 443,
          "requestPath": "/health",
          "intervalInSeconds": 5,
          "numberOfProbes": 1
        }
      }
    ],
    "loadBalancingRules": [
      {
        "name": "https",
        "properties": {
          "frontendIPConfiguration": {
            "id": "[resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', parameters('lbName'), 'frontend1')]"
          },
          "frontendPort": 443,
          "backendPort": 443,
          "enableFloatingIP": false,
          "idleTimeoutInMinutes": 4,
          "protocol": "TCP",
          "loadDistribution": "Default",
          "probe": {
            "id": "[resourceId('Microsoft.Network/loadBalancers/probes', parameters('lbName'), 'https')]"
          },
          "disableOutboundSnat": true,
          "enableTcpReset": false,
          "backendAddressPools": [
            {
              "id": "[resourceId('Microsoft.Network/loadBalancers/backendAddressPools', parameters('lbName'), 'backend1')]"
            }
          ]
        }
      }
    ],
    "inboundNatRules": [],
    "outboundRules": []
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('name'), 'GatewaySubnet')]"
  ]
}
```

### Configure with Bicep

To deploy load balancers that pass this rule:

- Configure HTTP or HTTPS based probes on ports that commonly use HTTP or HTTPS protocols.
  - Set the `properties.probes[*]` property to include a probe with the following properties:
    - `properties.probes[*].properties.protocol` set to `HTTPS`.
    - `properties.probes[*].properties.requestPath` set to `/health`.

For example:

```bicep
resource https_lb 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontend1'
        properties: {
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet01.id
          }
        }
        zones: [
          '2'
          '3'
          '1'
        ]
      }
    ]
    backendAddressPools: [
      {
        name: 'backend1'
      }
    ]
    probes: [
      {
        name: 'https'
        properties: {
          protocol: 'HTTPS'
          port: 443
          requestPath: '/health'
          intervalInSeconds: 5
          numberOfProbes: 1
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'frontend1')
          }
          frontendPort: 443
          backendPort: 443
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'TCP'
          loadDistribution: 'Default'
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'https')
          }
          disableOutboundSnat: true
          enableTcpReset: false
          backendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'backend1')
            }
          ]
        }
      }
    ]
    inboundNatRules: []
    outboundRules: []
  }
}
```

<!-- external:avm avm/res/network/load-balancer probes -->

## NOTES

This rule only applies to probes for ports that commonly use HTTP or HTTPS protocols.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Load Balancer health probes](https://learn.microsoft.com/azure/load-balancer/load-balancer-custom-probe-overview)
- [Health Endpoint Monitoring pattern](https://learn.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
- [Reliability in Load Balancer](https://learn.microsoft.com/azure/reliability/reliability-load-balancer)
- [Health Probes](https://learn.microsoft.com/azure/reliability/reliability-load-balancer#health-probes)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/loadbalancers)

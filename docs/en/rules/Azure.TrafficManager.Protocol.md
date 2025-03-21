---
reviewed: 2024-01-27
severity: Important
pillar: Security
category: SE:07 Encryption
resource: Traffic Manager
resourceType: Microsoft.Network/trafficManagerProfiles
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.TrafficManager.Protocol/
---

# Use HTTPS to monitor web-based endpoints

## SYNOPSIS

Monitor Traffic Manager web-based endpoints with HTTPS.

## DESCRIPTION

Traffic Manager can use TCP, HTTP or HTTPS to monitor endpoint health.
For web-based endpoints use HTTPS.

If TCP is used, Traffic Manager only checks that it can open a TCP port on the endpoint.
This alone does not indicate that the endpoint is operational and ready to receive requests.
Additionally when using HTTP and HTTPS, Traffic Manager check HTTP response codes.

If HTTP is used, Traffic Manager will send unencrypted health checks to the endpoint.
HTTPS-based health checks additionally check if a certificate is present,
but do not validate if the certificate is valid.

## RECOMMENDATION

Consider using HTTPS to monitor web-based endpoint health.
HTTPS-based monitoring improves security and increases accuracy of health probes.

## EXAMPLES

### Configure with Azure template

To deploy Traffic Manager profiles that pass this rule:

- Set the `properties.monitorConfig.protocol` property to `HTTPS` for HTTP-based endpoints.

For example:

```json
{
  "type": "Microsoft.Network/trafficmanagerprofiles",
  "apiVersion": "2022-04-01",
  "name": "[parameters('name')]",
  "location": "global",
  "properties": {
    "endpoints": "[parameters('endpoints')]",
    "trafficRoutingMethod": "Performance",
    "monitorConfig": {
      "protocol": "HTTPS",
      "port": 443,
      "intervalInSeconds": 30,
      "timeoutInSeconds": 5,
      "toleratedNumberOfFailures": 3,
      "path": "/healthz"
    }
  }
}
```

### Configure with Bicep

To deploy Traffic Manager profiles that pass this rule:

- Set the `properties.monitorConfig.protocol` property to `HTTPS` for HTTP-based endpoints.

For example:

```bicep
resource profile 'Microsoft.Network/trafficmanagerprofiles@2022-04-01' = {
  name: name
  location: 'global'
  properties: {
    endpoints: endpoints
    trafficRoutingMethod: 'Performance'
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      intervalInSeconds: 30
      timeoutInSeconds: 5
      toleratedNumberOfFailures: 3
      path: '/healthz'
    }
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [Traffic Manager endpoint monitoring](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-monitoring)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/trafficmanagerprofiles)

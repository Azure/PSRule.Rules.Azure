---
severity: Important
pillar: Security
category: Network security and containment
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.PublicAccess/
---

# Disable public access

## SYNOPSIS

Ensure public network access for Container Apps environment is disabled.

## DESCRIPTION

Container apps environments allows you to expose your container app to the public web. 

Container apps environments deployed as external resources are available for public requests. External environments are deployed with a virtual IP on an external, public facing IP address.

Disable public network access to improve security by exposing the Container Apps environment through an internal load balancer. This removes the need for a public IP address and prevents internet access to all Container Apps within the environment.

## RECOMMENDATION

Consider disabling public network access.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps environments that pass this rule:

- Provide a custom VNET.
- Set `properties.vnetConfiguration.internal` to `true`.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2022-10-01",
  "name": "[parameters('envName')]",
  "location": "[parameters('location')]",
  "properties": {
    "vnetConfiguration": {
      "dockerBridgeCidr": "[parameters('dockerBridgeCidr')]",
      "infrastructureSubnetId": "[parameters('infrastructureSubnetId')]",
      "internal": true,
      "outboundSettings": {},
      "platformReservedCidr": "[parameters('platformReservedCidr')]",
      "platformReservedDnsIP": "[parameters('platformReservedDnsIP')]",
    }
  }
}
```

### Configure with Bicep

To deploy Container Apps environments that pass this rule:

- Provide a custom VNET.
- Set `properties.vnetConfiguration.internal` to `true`.

For example:

```bicep
resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: envName
  location: location
  properties: {
    vnetConfiguration: {
    dockerBridgeCidr: dockerBridgeCidr
    infrastructureSubnetId: infrastructureSubnetId
    internal: true
    outboundSettings: {}
    }
    platformReservedCidr: platformReservedCidr
    platformReservedDnsIP: platformReservedDnsIP
  }
}
```

## LINKS

- [Networking architecture in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/networking)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/managedenvironments#vnetconfiguration)

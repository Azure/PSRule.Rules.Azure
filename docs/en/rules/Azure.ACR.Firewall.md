---
severity: Important
pillar: Security
category: Application endpoints
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.Firewall/
---

# Restrict network access to container registries

## SYNOPSIS

Limit network access of container registries to only trusted clients.

## DESCRIPTION

Azure Container Registry (ACR) allows you to restrict network access to trusted clients and networks instead of any client.

Container registries using the Premium SKU can limit network access by setting firewall rules or using private endpoints.
Firewall and private endpoints are not supported when using the Basic or Standard SKU.

In general, network access should be restricted to harden against unauthorized access or exfiltration attempts.
However may not be required when publishing and distributing public container images to external parties.

## RECOMMENDATION

Consider restricting network access to trusted clients to harden against unauthorized access or exfiltration attempts.

## EXAMPLES

### Configure with Azure template

To deploy Azure Container Registries that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`. OR
- Set the `properties.networkRuleSet.defaultAction` property to `Deny`.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2023-01-01-preview",
  "name": "[parameters('registryName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium"
  },
  "properties": {
    "publicNetworkAccess": "Enabled",
    "networkRuleBypassOptions": "AzureServices",
    "networkRuleSet": {
      "defaultAction": "Deny",
      "ipRules": [
        {
          "action": "Allow",
          "value": "_PublicIPv4Address_"
        }
      ]
    }
  }
}
```

### Configure with Bicep

To deploy Azure Container Registries that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`. OR
- Set the `properties.networkRuleSet.defaultAction` property to `Deny`.

For example:

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: '_PublicIPv4Address_'
        }
      ]
    }
  }
}
```

<!-- external:avm avm/res/container-registry/registry publicNetworkAccess -->

## NOTES

Configuring firewall rules or using private endpoints is only available for the Premium SKU.

When used with Microsoft Defender for Containers, you must enable trusted Microsoft services for the vulnerability assessment feature to be able to scan the registry.

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/well-architected/security/design-network-endpoints)
- [Restrict access using private endpoint](https://learn.microsoft.com/azure/container-registry/container-registry-private-link)
- [Restrict access using firewall rules](https://learn.microsoft.com/azure/container-registry/container-registry-access-selected-networks)
- [Allow trusted services to securely access a network-restricted container registry](https://learn.microsoft.com/azure/container-registry/allow-access-trusted-services)
- [Vulnerability assessments for Azure with Microsoft Defender Vulnerability Management](https://learn.microsoft.com/azure/defender-for-cloud/agentless-container-registry-vulnerability-assessment)
- [Azure security baseline for Container Registry](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#ns-2-secure-cloud-services-with-network-controls)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries#registryproperties)

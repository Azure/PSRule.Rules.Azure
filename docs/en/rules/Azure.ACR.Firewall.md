---
severity: Important
pillar: Security
category: Application endpoints
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.Firewall/
---

# Restrict network access

## SYNOPSIS

Restrict network access.

## DESCRIPTION

Azure Container Registry (ACR) allows you to restrict network access.
Network restriction can be implemented by firewall rules or private endpoints.

A container registry should accept explicitly allowed traffic only.

However, no network access restriction can be used in scenarios that do not require network restriction such as distributing public container images.

## RECOMMENDATION

Consider restricting network access in scenarios that require explicitly allowed traffic only.

## EXAMPLES

### Configure with Azure template

To deploy Azure Container Registries that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled` or `properties.networkRuleSet.defaultAction` property to `Deny`.

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

- Set the `properties.publicNetworkAccess` property to `Disabled` or `properties.networkRuleSet.defaultAction` property to `Deny`.

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
- [Azure deployment reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries#registryproperties)

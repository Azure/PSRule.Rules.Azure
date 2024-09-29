---
reviewed: 2024-06-18
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.RestrictIngress/
---

# IP ingress restrictions mode

## SYNOPSIS

IP ingress restrictions mode should be set to allow action for all rules defined.

## DESCRIPTION

Container apps supports restricting inbound traffic by IP addresses.

This allows container apps to restrict inbound HTTP or TCP traffic by allowing or denying access to a specific list of IP address ranges.

However, configuring a rule with the `Deny` action leads to traffic being denied from the IPv4 address or range, but allows all other traffic.

Instead by configuring a rule or multiple rules with the `Allow` action traffic is allowed from the IPv4 address or range, but denies all other traffic.

When no IP restriction rules are defined, all inbound traffic is allowed.

IP ingress restrictions mode can be used for container apps within external and internal environments, but internal ones are limited to private addresses only, where external ones supports both public and private addresses.

## RECOMMENDATION

Consider configuring IP restrictions to limit ingress traffic to allowed IP addresses.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Create one or more rules to allow traffic by configuring `properties.configuration.ingress.ipSecurityRestrictions`.
- For each rule defined in `properties.configuration.ingress.ipSecurityRestrictions` to action `Allow`.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2024-03-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "environmentId": "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]",
    "template": {
      "revisionSuffix": "[parameters('revision')]",
      "containers": "[variables('containers')]",
      "scale": {
        "minReplicas": 2
      }
    },
    "configuration": {
      "ingress": {
        "allowInsecure": false,
        "ipSecurityRestrictions": [
          {
            "action": "Allow",
            "description": "Allowed IP address range",
            "ipAddressRange": "10.1.1.1/32",
            "name": "ClientIPAddress_1"
          },
          {
            "action": "Allow",
            "description": "Allowed IP address range",
            "ipAddressRange": "10.1.2.1/32",
            "name": "ClientIPAddress_2"
          }
        ],
        "stickySessions": {
          "affinity": "none"
        }
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]"
  ]
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Create one or more rules to allow traffic by configuring `properties.configuration.ingress.ipSecurityRestrictions`.
- For each rule defined in `properties.configuration.ingress.ipSecurityRestrictions` to action `Allow`.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerEnv.id
    template: {
      revisionSuffix: revision
      containers: containers
      scale: {
        minReplicas: 2
      }
    }
    configuration: {
      ingress: {
        allowInsecure: false
        ipSecurityRestrictions: [
          {
            action: 'Allow'
            description: 'Allowed IP address range'
            ipAddressRange: '10.1.1.1/32'
            name: 'ClientIPAddress_1'
          }
          {
            action: 'Allow'
            description: 'Allowed IP address range'
            ipAddressRange: '10.1.2.1/32'
            name: 'ClientIPAddress_2'
          }
        ]
        stickySessions: {
          affinity: 'none'
        }
      }
    }
  }
}
```

<!-- external:avm avm/res/app/container-app:0.11.0 ipSecurityRestrictions -->

## NOTES

All rules must be the same type.
It is not supported to combine allow rules and deny rules.
If no rules are defined at all, the rule will not pass as it expects at least one allow rule to be configured.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [NS-2: Secure cloud services with network controls](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-container-apps-security-baseline#ns-2-secure-cloud-services-with-network-controls)
- [Networking in Azure Container Apps environment](https://learn.microsoft.com/azure/container-apps/networking)
- [IP restrictions](https://learn.microsoft.com/azure/container-apps/ingress-overview#ip-restrictions)
- [Set up IP ingress restrictions in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/ip-restrictions)
- [Azure security baseline for Azure Container Apps](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-container-apps-security-baseline)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#ipsecurityrestrictionrule)

---
severity: Critical
pillar: Security
category: Encryption
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.MinTLS/
---

# Front Door Minimum TLS

## SYNOPSIS

Front Door should reject TLS versions older then 1.2.

## DESCRIPTION

The minimum version of TLS that Azure Front Door accepts is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Front Door lets you disable outdated protocols and enforce TLS 1.2.
By default, a minimum of TLS 1.2 is enforced.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.

## EXAMPLES

### Configure with Azure template

To deploy a Front Door resource that passes this rule:

- Set the minTlsVersion to be '1.2'

For example:

```json
  "resources": [
    {
      "type": "Microsoft.Cdn/profiles",
      "apiVersion": "2021-06-01",
      "name": "[parameters('frontDoorName')]",
      "location": "Global",
      "sku": {
        "name": "Standard_AzureFrontDoor"
      }
    },
    {
      "type": "Microsoft.Web/serverfarms",
      "apiVersion": "2020-06-01",
      "name": "[variables('frontDoorAppServicePlanName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "S1",
        "capacity": 1
      },
      "kind": "app"
    },
    {
      "type": "Microsoft.Web/sites",
      "apiVersion": "2020-06-01",
      "name": "[variables('frontDoorAppName')]",
      "location": "[parameters('location')]",
      "kind": "app",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', variables('frontDoorAppServicePlanName'))]",
        "httpsOnly": true,
        "siteConfig": {
          "detailedErrorLoggingEnabled": true,
          "httpLoggingEnabled": true,
          "requestTracingEnabled": true,
          "ftpsState": "Disabled",
          "minTlsVersion": "1.2",
          "ipSecurityRestrictions": [
            {
              "tag": "ServiceTag",
              "ipAddress": "AzureFrontDoor.Backend",
              "action": "Allow",
              "priority": 100,
              "headers": {
                "x-azure-fdid": [
                  "[reference(resourceId('Microsoft.Cdn/profiles', parameters('frontDoorName'))).frontDoorId]"
                ]
              },
              "name": "Allow traffic from Front Door"
            }
          ]
        }
      },
      "dependsOn": [
        "[resourceId('Microsoft.Web/serverfarms', variables('frontDoorAppServicePlanName'))]",
        "[resourceId('Microsoft.Cdn/profiles', parameters('frontDoorName'))]"
      ]
    }
  ]
```

### Configure with Bicep

To deploy a Front Door resource that passes this rule:

- Set the minTlsVersion to be '1.2'

For example:

```bicep
resource frontDoorResource 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorName
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}
resource appServicePlanResource 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: frontDoorAppServicePlanName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
  kind: 'app'
}

resource appResource 'Microsoft.Web/sites@2020-06-01' = {
  name: frontDoorAppName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanResource.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorResource.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
    }
  }
}
```

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [What TLS versions are supported by Azure Front Door Service?](https://docs.microsoft.com/azure/frontdoor/front-door-faq#what-tls-versions-are-supported-by-azure-front-door-service)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.network/frontdoors/frontendendpoints)

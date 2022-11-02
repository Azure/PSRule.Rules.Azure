---
severity: Important
pillar: Operational Excellence
category: Infrastructure provisioning
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.MinAPIVersion/
---

# API Management API versions prior to 2021-08-01 will be retired

## SYNOPSIS

API Management instances with API versions prior to 2021-08-01 must update.

## DESCRIPTION

On 30 September 2023, all API versions prior to 2021-08-01 will be retired and API calls using those API versions will fail. This means you'll no longer be able to create or manage your API Management services using your existing templates, tools, scripts, and programs until they've been updated. Data operations (such as accessing the APIs or Products configured on Azure API Management) will be unaffected by this update, including after 30 September 2023.

From now through 30 September 2023, you can continue to use the templates, tools, and programs without impact. You can transition to API version 2021-08-01 or later at any point prior to 30 September 2023.

## RECOMMENDATION

Update the API version to '2021-08-01' or newer.

## EXAMPLES

### Configure with Azure template

To deploy API Management instances that pass this rule:

- Set the `apiVersion` to `'2021-08-01'` or newer.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.11.1.770",
      "templateHash": "15781462834380085690"
    }
  },
  "parameters": {
    "apiManagementServiceName": {
      "type": "string",
      "defaultValue": "[format('apiservice{0}', uniqueString(resourceGroup().id))]",
      "metadata": {
        "description": "The name of the API Management service instance"
      }
    },
    "publisherEmail": {
      "type": "string",
      "defaultValue": "psruleazureadmin@psrule.com",
      "minLength": 1,
      "metadata": {
        "description": "The email address of the owner of the service"
      }
    },
    "publisherName": {
      "type": "string",
      "defaultValue": "PSRuleAzure",
      "minLength": 1,
      "metadata": {
        "description": "The name of the owner of the service"
      }
    },
    "sku": {
      "type": "string",
      "defaultValue": "Developer",
      "allowedValues": [
        "Developer",
        "Standard",
        "Premium"
      ],
      "metadata": {
        "description": "The pricing tier of this API Management service"
      }
    },
    "skuCount": {
      "type": "int",
      "defaultValue": 1,
      "allowedValues": [
        1,
        2
      ],
      "metadata": {
        "description": "The instance size of this API Management service."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for all resources."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ApiManagement/service",
      "apiVersion": "2021-12-01-preview",
      "name": "[parameters('apiManagementServiceName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "[parameters('sku')]",
        "capacity": "[parameters('skuCount')]"
      },
      "properties": {
        "publisherEmail": "[parameters('publisherEmail')]",
        "publisherName": "[parameters('publisherName')]"
      }
    }
  ]
}
```

### Configure with Bicep

To deploy API Management instances that pass this rule:

- Set the `apiVersion` to `'2021-08-01'` or newer.

For example:

```bicep
@description('The name of the API Management service instance')
param apiManagementServiceName string = 'apiservice${uniqueString(resourceGroup().id)}'

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string = 'psruleazureadmin@psrule.com'

@description('The name of the owner of the service')
@minLength(1)
param publisherName string = 'PSRuleAzure'

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

resource apiManagementService 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apiManagementServiceName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}
```

## LINKS

- [Azure API Management API version retirements](https://learn.microsoft.com/azure/api-management/breaking-changes/api-version-retirement-sep-2023)
- [Azure template reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)

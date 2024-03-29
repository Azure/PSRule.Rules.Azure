---
severity: Consciente
pillar: Excelencia operativa
category: Infraestructura repetible
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/es/rules/Azure.ACR.Name/
---

# Utilice nombres de registro válidos

## Sinopsis

Los nombres de registro de contenedores deben cumplir con los requisitos de denominación.

## Descripción

Al nombrar los recursos de Azure, los nombres de los recursos deben cumplir con los requisitos del servicio.
Los requisitos para los nombres de registro de contenedores son:

- Entre 5 y 50 caracteres de longitud.
- Alfanuméricos.
- Los nombres de registros de contenedores deben ser únicos a nivel mundial.

## Recomendación

Considere usar nombres que cumplan con los requisitos de nombres del registro de contenedores.
Además, considere nombrar recursos con una convención de nomenclatura estándar.

## Ejemplos

### Configurar con plantilla de ARM

Puede asegurarse de que el parámetro `acrName` cumpla con los requisitos de nomenclatura utilizando las propiedades de los parámetros `MinLength` y `maxLength`.
También puede usar una función `uniqueString()` para asegurarse de que el nombre sea globalmente único.

Por ejemplo

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "acrName": {
      "type": "string",
      "defaultValue": "[format('acr{0}', uniqueString(resourceGroup().id))]",
      "maxLength": 50,
      "minLength": 5,
      "metadata": {
        "description": "Globally unique name of your Azure Container Registry"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for registry home replica."
      }
    },
    "acrSku": {
      "type": "string",
      "defaultValue": "Premium",
      "allowedValues": [
        "Standard"
        "Premium"
      ],
      "metadata": {
        "description": "Tier of your Azure Container Registry."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerRegistry/registries",
      "apiVersion": "2019-12-01-preview",
      "name": "[parameters('acrName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "[parameters('acrSku')]"
      },
      "tags": {
        "displayName": "Container Registry",
        "container.registry": "[parameters('acrName')]"
      }
    }
  ],
  "outputs": {
    "acrLoginServer": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))).loginServer]"
    }
  }
}
```

### Configurar con Bicep

Puede asegurarse de que el parámetro `acrName` cumpla con los requisitos de nomenclatura utilizando las propiedades de los parámetros `MinLength` y `maxLength`.
También puede usar una función `uniqueString()` para asegurarse de que el nombre sea globalmente único.

Por ejemplo:

```bicep
@description('Globally unique name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Location for registry home replica.')
param location string = resourceGroup().location

@description('Tier of your Azure Container Registry. Geo-replication requires Premium SKU.')
@allowed([
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
}

output acrLoginServer string = containerRegistry.properties.loginServer
```

## Notas

Esta regla no comprueba si los nombres de registro de contenedores son únicos.

## Enlaces

- [Infraestructura repetible](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Reglas y restricciones de nomenclatura para los recursos de Azure](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Abreviaturas recomendadas para los tipos de recursos de Azure](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Referencia de implementación de Azure](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)

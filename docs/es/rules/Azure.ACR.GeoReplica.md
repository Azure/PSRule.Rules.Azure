---
severity: Importante
pillar: Confiabilidad
category: Protección de datos
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/es/rules/Azure.ACR.GeoReplica/
---

# Geo-replicar imágenes de contenedores

## Sinopsis

Utilice registros de contenedores replicados geográficamente para complementar las implementaciones de contenedores en varias regiones.

## Descripción

Un registro de contenedor se almacena y mantiene de forma predeterminada en una sola región.
Opcionalmente, se puede habilitar la replicación geográfica en una o más regiones adicionales.

Los registros de contenedores de replicación geográfica brindan los siguientes beneficios:

- Los nombres únicos de registros/imágenes/etiquetas se pueden usar en múltiples regiones.
- El acceso al registro de cierre de red dentro de la región reduce la latencia.
- Como las imágenes se extraen de un registro replicado local, cada extracción no genera costos de salida adicionales.

## Recomendación

Considere usar un registro de contenedor replicado geográficamente para implementaciones en varias regiones.

## Ejemplos

### Configurar con plantilla de ARM

Para habilitar la replicación geográfica para registros de contenedores que pasan esta regla:

- Establezca `sku.name` a `Premium` (necesario para la replicación geográfica).
- Agrega el recurso secundario `replications` con `location` establecida en la región para replicar.

Por ejemplo:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.5.6.12127",
      "templateHash": "12610175857982700190"
    }
  },
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
    "acrAdminUserEnabled": {
      "type": "bool",
      "defaultValue": false,
      "metadata": {
        "description": "Enable admin user that has push / pull permission to the registry."
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
      "allowedValues": ["Premium"],
      "metadata": {
        "description": "Tier of your Azure Container Registry. Geo-replication requires Premium SKU."
      }
    },
    "acrReplicaLocation": {
      "type": "string",
      "metadata": {
        "description": "Short name for registry replica location."
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
      },
      "properties": {
        "adminUserEnabled": "[parameters('acrAdminUserEnabled')]"
      }
    },
    {
      "type": "Microsoft.ContainerRegistry/registries/replications",
      "apiVersion": "2019-12-01-preview",
      "name": "[format('{0}/{1}', parameters('acrName'), parameters('acrReplicaLocation'))]",
      "location": "[parameters('acrReplicaLocation')]",
      "properties": {},
      "dependsOn": [
        "[resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))]"
      ]
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

Para habilitar la replicación geográfica para registros de contenedores que pasan esta regla:

- Establezca `sku.name` a `Premium` (necesario para la replicación geográfica).
- Agrega el recurso secundario `replications` con `location` establecida en la región para replicar.

Por ejemplo:

```bicep
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Premium'
  }
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource containerRegistryReplica 'Microsoft.ContainerRegistry/registries/replications@2019-12-01-preview' = {
  parent: containerRegistry
  name: '${acrReplicaLocation}'
  location: acrReplicaLocation
  properties: {
  }
}
```

## Notas

Esta regla se aplica cuando se analizan los recursos implementados en Azure.

## Elaces

- [Resistencia y dependencias](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
- [Implementación de la replicación geográfica en varias regiones](https://learn.microsoft.com/azure/container-registry/container-registry-best-practices#geo-replicate-multi-region-deployments)
- [Replicación geográfica en Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Tutorial: Preparar un registro de contenedor de Azure con replicación geográfica](https://learn.microsoft.com/azure/container-registry/container-registry-tutorial-prepare-registry)

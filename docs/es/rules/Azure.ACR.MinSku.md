---
reviewed: 2022-09-27
severity: Importante
pillar: Confiabilidad
category: Requisitos
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/es/rules/Azure.ACR.MinSku/
---

# Utilice el SKU de producción de ACR

## Sinopsis

ACR debe usar el SKU Premium o Estándar para las implementaciones de producción.

## Descripción

Azure Container Registry (ACR) proporciona una gama de diferentes niveles de servicio (también conocidos como SKU).
Estos niveles de servicio proporcionan diferentes niveles de rendimiento y características.

Hay tres niveles de servicio disponibles: Básico, Estándar y Premium.
Los registros de contenedores básicos solo se recomiendan para implementaciones que no sean de producción.
Utilice un mínimo de Estándar para registros de contenedores de producción.

El SKU Premium proporciona un mayor rendimiento de imágenes y almacenamiento incluido, y es necesario para:

- Geo-replicación
- Zonas de disponibilidad
- Puntos de conexión privados
- Restricciones de firewall
- Tokens y mapas de alcance

## Recomendación

Considere usar el SKU de Premium de registros de contenedores para implementaciones de producción.

## Ejemplos

### Configurar con plantilla de ARM

Para implementar registros de contenedores que superen esta regla:

- Establezca `sku.name` a `Premium` o `Standard`.

Por ejemplo:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2021-06-01-preview",
  "name": "[parameters('registryName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "adminUserEnabled": false,
    "policies": {
      "quarantinePolicy": {
        "status": "enabled"
      },
      "trustPolicy": {
        "status": "enabled",
        "type": "Notary"
      },
      "retentionPolicy": {
        "status": "enabled",
        "days": 30
      }
    }
  }
}
```

### Configurar con Bicep

Para implementar registros de contenedores que superen esta regla:

- Establezca `sku.name` a `Premium` o `Standard`.

Por ejemplo:

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 30
      }
    }
  }
}
```

## Elaces

- [Requisitos no funcionales y de destino](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [Niveles del servicio Azure Container Registry](https://docs.microsoft.com/azure/container-registry/container-registry-skus)
- [Replicación geográfica en Azure Container Registry](https://docs.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Implementación de la replicación geográfica en varias regiones](https://docs.microsoft.com/azure/container-registry/container-registry-best-practices#geo-replicate-multi-region-deployments)
- [Referencia de implementación de Azure](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)

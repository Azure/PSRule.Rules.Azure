---
severity: Importante
pillar: Optimización de costos
category: Utilización de recursos
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/es/rules/Azure.ACR.Retention/
---

# Configurar directiva de retención de ACR

## Sinopsis

Use una directiva de retención para limpiar los manifiestos sin etiquetar.

## Descripción

La directiva de retención es una opción configurable de Premium Azure Container Registry (ACR).
Cuando se configura una directiva de retención, los manifiestos sin etiquetar en el registro se eliminan automáticamente.
Un manifiesto no está etiquetado cuando se envía una imagen más reciente con la misma etiqueta. es decir, lo último.

La directiva de retención (en días) se puede establecer en 0-365.
El valor predeterminado es 7 días.

Para configurar una directiva de retención, el registro del contenedor debe usar una SKU Premium.

## Recomendación

Considere habilitar una directiva de retención para manifiestos sin etiquetar.

## Ejemplos

### Configurar con plantilla de ARM

Para implementar registros de contenedores que superen esta regla:

- Establezca `properties.retentionPolicy.status` a `enabled`.

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

- Establezca `properties.retentionPolicy.status` a `enabled`.

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

## Notas

Las directivas de retención para Azure Container Registry están actualmente en versión preliminar.

## Enlaces

- [Almacenamiento escalable](https://docs.microsoft.com/azure/container-registry/container-registry-storage#scalable-storage)
- [Establecimiento de una directiva de retención para manifiestos sin etiqueta](https://docs.microsoft.com/azure/container-registry/container-registry-retention-policy)
- [Bloqueo de una imagen de contenedor en una instancia de Azure Container Registry](https://docs.microsoft.com/azure/container-registry/container-registry-image-lock)
- [Referencia de implementación de Azure](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)

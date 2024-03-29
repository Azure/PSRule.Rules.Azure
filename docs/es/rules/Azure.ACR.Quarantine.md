---
reviewed: 2022-09-27
severity: Importante
pillar: Seguridad
category: Recursos de Azure
resource: Container Registry
preview: true
online version: https://azure.github.io/PSRule.Rules.Azure/es/rules/Azure.ACR.Quarantine/
---

# Utilice patrón de cuarentena de imagen de contenedor

## Sinopsis

Habilite la cuarentena de imágenes de contenedores, escanee y marque imágenes como verificadas.

## Descripción

La cuarentena de imágenes es una opción configurable para Azure Container Registry (ACR).
Cuando está habilitado, las imágenes enviadas al registro del contenedor no están disponibles de forma predeterminada.
Cada imagen debe verificarse y marcarse como `Aprobada` antes de que esté disponible para extraer.

Para verificar imágenes de contenedores, integre con una herramienta de seguridad externa que admita esta función.

## Recomendación

Considere configurar una herramienta de seguridad para implementar el patrón de cuarentena de imágenes.
Habilite la cuarentena de imágenes en el registro de contenedores para garantizar que cada imagen se verifique antes de su uso.

## Ejemplos

### Configurar con plantilla de ARM

Para implementar registros de contenedores que superen esta regla:

- Establezca `properties.quarantinePolicy.status` a `enabled`.

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

- Establezca `properties.quarantinePolicy.status` a `enabled`.

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

La cuarentena de imágenes para Azure Container Registry se encuentra actualmente en versión preliminar.

## Enlaces

- [Supervisión de recursos de Azure en Microsoft Defender for Cloud](https://learn.microsoft.com/azure/architecture/framework/security/monitor-resources#containers)
- [¿Cómo se habilita la cuarentena automática de imágenes para un registro?](https://learn.microsoft.com/azure/container-registry/container-registry-faq#how-do-i-enable-automatic-image-quarantine-for-a-registry-)
- [Patrón de cuarentena](https://github.com/Azure/acr/tree/main/docs/preview/quarantine)
- [Proteger las imágenes y el tiempo de ejecución](https://learn.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
- [Referencia de implementación de Azure](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)

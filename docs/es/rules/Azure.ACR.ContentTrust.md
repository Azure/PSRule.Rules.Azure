---
severity: Importante
pillar: Seguridad
category: Protección de datos
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/es/rules/Azure.ACR.ContentTrust/
---

# Utilica imágenes de contenedores de confianza

## Sinopsis

Utilica imágenes de contenedores firmadas por un publicador de imágenes de confianza.
Use container images signed by a trusted image publisher.

## Descripción

La confianza en el contenido de Azure Container Registry (ACR) permite insertar y extraer imágenes firmadas.
Las imágenes firmadas brindan una garantía adicional de que se han creado en una fuente confiable.
Para habilitar la confianza en el contenido, el registro del contenedor debe usar una SKU Premium.

## Recomendación

Considere habilitar la confianza en el contenido en registros, clientes e imágenes de contenedores de firmas.

## Ejemplos

### Configurar con plantilla de ARM

Para implementar resgistros de contenedores que superen esta regla:

- Establezca `properties.trustPolicy.status` a `enabled`.
- Establezca `properties.trustPolicy.type` a `Notary`.

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

Para implementar resgistros de contenedores que superen esta regla:

- Establezca `properties.trustPolicy.status` a `enabled`.
- Establezca `properties.trustPolicy.type` a `Notary`.

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

## Enlaces

- [Confianza en el contenido en Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-content-trust)
- [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/)
- [Referencia de implementación de Azure](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)

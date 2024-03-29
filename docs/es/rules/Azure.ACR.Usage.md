---
reviewed: 2022-09-27
severity: Importante
pillar: Optimización de costos
category: Reportes
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/es/rules/Azure.ACR.Usage/
---

# Uso del almacenamiento del registro de contenedores

## Sinopsis

Elimine periódicamente las imágenes obsoletas e innecesarias para reducir el uso del almacenamiento.

## Descripción

Cada SKU de ACR tiene una cantidad de almacenamiento incluido.
Cuando se excede la cantidad de almacenamiento incluido, se acumulan costos de almacenamiento adicionales por GiB.

Es una buena práctica limpiar regularmente las imágenes huérfanas.
Estas imágenes son el resultado de enviar imágenes actualizadas con la misma etiqueta.

## Recomendación

Considere eliminar las imágenes obsoletas e innecesarias para reducir el consumo de almacenamiento.
También considere actualizar a Premium SKU para registros básicos o estándar para aumentar el almacenamiento incluido.

## Notas

Esta regla se aplica cuando se analizan los recursos implementados en Azure.

## Enlaces

- [Generar informes de costos](https://learn.microsoft.com/azure/architecture/framework/cost/monitor-reports)
- [Niveles del servicio Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-skus)
- [Almacenamiento escalable](https://learn.microsoft.com/azure/container-registry/container-registry-storage#scalable-storage)
- [Administración del tamaño del registro](https://learn.microsoft.com/azure/container-registry/container-registry-best-practices#manage-registry-size)
- [Eliminación de imágenes de contenedor en Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-delete)

---
reviewed: 2022-09-23
severity: Critico
pillar: Seguridad
category: Recursos de Azure
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/es/rules/Azure.ACR.ContainerScan/
---

# Examen de imágenes del registro

## Sinopsis

Habilite el análisis de vulnerabilidades para imágenes de contenedores.

## Descripción

Un riesgo potencial con las cargas de trabajo basadas en contenedores son las vulnerabilidades de seguridad sin parches en:

- Imágenes base del sistema operativo.
- Marcos y dependencias de tiempo de ejecución utilizados por el código de la aplicación.

Es importante adoptar una estrategia para escanear activamente las imágenes en busca de vulnerabilidades de seguridad.
Una opción para escanear imágenes de contenedores es usar Microsoft Defender para registros de contenedores.
Microsoft Defender para registros de contenedores analiza cada imagen de contenedor enviada al registro.

Microsoft Defender para registros de contenedores analiza imágenes en imágenes insertadas, importadas y extraídas recientemente.
Las imágenes extraídas recientemente se escanean periódicamente cuando se extrajeron en los últimos 30 días.
Cualquier vulnerabilidad detectada se informa a Microsoft Defender for Cloud.

Escaneo de vulnerabilidades de imágenes de contenedores con Microsoft Defender para registros de contenedores:

- Actualmente solo está disponible para registros ACR alojados en Linux.
- El registro de contenedores debe ser accesible para los registros de contenedores de Microsoft Defender.
  El acceso a la red no puede estar restringido por firewall, puntos de conexión de servicio o puntos de conexión privados.
- Es compatible para clientes de la nube comerciales.
  Actualmente no se admite en nubes soberanas o nacionales (por ejemplo, gobierno de EE. UU., gobierno de China, etc.).

## Recomendación

Considere usar Microsoft Defender para la nube para buscar vulnerabilidades de seguridad en imágenes de contenedores.

## Ejemplos

### Configurar con plantilla de ARM

Para habilitar el escaneo de imágenes de contenedores:

- Establezca `pricingTier` a `Standard` para Microsoft Defender para container registries.

Por ejemplo:

```json
{
  "type": "Microsoft.Security/pricings",
  "apiVersion": "2018-06-01",
  "name": "ContainerRegistry",
  "properties": {
    "pricingTier": "Standard"
  }
}
```

### Configurar con Bicep

Para habilitar el escaneo de imágenes de contenedores:

- Establezca `pricingTier` a `Standard` para Microsoft Defender para container registries.

Por ejemplo:

```bicep
resource defenderForContainerRegistry 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'ContainerRegistry'
  properties: {
    pricingTier: 'Standard'
  }
}
```

### Configurar con Azure CLI

```bash
az security pricing create -n 'ContainerRegistry' --tier 'standard'
```

### Configurar con Azure PowerShell

```powershell
Set-AzSecurityPricing -Name 'ContainerRegistry' -PricingTier 'Standard'
```

## Notas

Esta regla se aplica cuando se analizan los recursos implementados en Azure.

## Enlaces

- [Supervisión de recursos de Azure en Microsoft Defender for Cloud](https://learn.microsoft.com/azure/architecture/framework/security/monitor-resources#containers)
- [Introducción a Microsoft Defender para registros de contenedor](https://learn.microsoft.com/azure/defender-for-cloud/defender-for-container-registries-introduction)
- [Introducción a Microsoft Defender for Containers](https://learn.microsoft.com/azure/defender-for-cloud/container-security)
- [Proteger las imágenes y el tiempo de ejecución](https://learn.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)

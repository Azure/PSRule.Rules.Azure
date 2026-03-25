---
reviewed: 2026-03-25
severity: Important
pillar: Reliability
category: RE:07 Self-preservation
resource: Container App
resourceType: Microsoft.App/containerApps
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.HealthProbe/
---

# Use HTTP health probes for HTTP-based ingress

## SYNOPSIS

Container app ingress that uses HTTP should have HTTP health probes configured for liveness and readiness checks.

## DESCRIPTION

Azure Container Apps supports health probes to determine the health and readiness of your containers.
Health probes can be configured as HTTP or TCP checks and support liveness, readiness, and startup probe types.

When a container app uses HTTP-based ingress (transport is `http` or `http2`, or the target port is `80`, `8080`, or `443`),
health probes should use HTTP checks (`httpGet`) for liveness and readiness probes.
HTTP health probes provide granular feedback by checking the HTTP response status code,
which gives more accurate information about whether a replica is available and ready to receive traffic compared to
a TCP port check which only determines if a port is open or closed.

The default health probes use TCP port checks when no probes are explicitly configured.
Configuring HTTP health probes instead allows the platform to better detect and respond to application-level failures.

Startup probes are excluded from this check as they are commonly configured as TCP for initial container startup purposes.

## RECOMMENDATION

Consider configuring HTTP health probes (`httpGet`) for liveness and readiness probes on containers
that use HTTP-based ingress.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- For each container in `properties.template.containers`:
  - Configure a `Liveness` probe with `httpGet` in the `probes` array.
  - Configure a `Readiness` probe with `httpGet` in the `probes` array.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2025-07-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "environmentId": "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]",
    "configuration": {
      "ingress": {
        "external": false,
        "targetPort": 8080,
        "transport": "http"
      }
    },
    "template": {
      "containers": [
        {
          "name": "app",
          "image": "[parameters('image')]",
          "probes": [
            {
              "type": "Liveness",
              "httpGet": {
                "path": "/healthz",
                "port": 8080
              },
              "initialDelaySeconds": 5,
              "periodSeconds": 10
            },
            {
              "type": "Readiness",
              "httpGet": {
                "path": "/healthz/ready",
                "port": 8080
              },
              "initialDelaySeconds": 5,
              "periodSeconds": 10
            }
          ]
        }
      ],
      "scale": {
        "minReplicas": 2
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]"
  ]
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- For each container in `properties.template.containers`:
  - Configure a `Liveness` probe with `httpGet` in the `probes` array.
  - Configure a `Readiness` probe with `httpGet` in the `probes` array.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2025-07-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerEnv.id
    configuration: {
      ingress: {
        external: false
        targetPort: 8080
        transport: 'http'
      }
    }
    template: {
      containers: [
        {
          name: 'app'
          image: image
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/healthz'
                port: 8080
              }
              initialDelaySeconds: 5
              periodSeconds: 10
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/healthz/ready'
                port: 8080
              }
              initialDelaySeconds: 5
              periodSeconds: 10
            }
          ]
        }
      ]
      scale: {
        minReplicas: 2
      }
    }
  }
}
```

<!-- external:avm avm/res/app/container-app containers[*].probes -->

## NOTES

This rule applies to container apps where the ingress transport is `http` or `http2`,
or where the target port is `80`, `8080`, or `443`.

Startup probes are excluded from this check.

When multiple containers are defined, each container must have both liveness and readiness HTTP probes configured.

## LINKS

- [RE:07 Self-preservation](https://learn.microsoft.com/azure/well-architected/reliability/self-preservation)
- [Health probes in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/health-probes)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#containerappprobe)

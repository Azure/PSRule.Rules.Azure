---
severity: Important
pillar: Security
category: SE:10 Monitoring and threat detection
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries,Microsoft.Insights/diagnosticSettings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.Logs/
---

# Audit Container Registry access

## SYNOPSIS

Ensure container registry audit diagnostic logs are enabled.

## DESCRIPTION

Azure Container Registry (ACR) provides diagnostic logs that can be used to monitor and audit access to container images.
Enabling audit logs helps you track who accesses your registry and when, which is important for security and compliance.

The following log categories should be enabled:

- `ContainerRegistryLoginEvents` - Captures authentication events to the registry.
- `ContainerRegistryRepositoryEvents` - Captures push and pull operations for container images.

Alternatively, you can enable the `audit` or `allLogs` category group to capture these and other audit events.

## RECOMMENDATION

Consider configuring diagnostic settings to capture container registry audit logs for security investigation.

## EXAMPLES

### Configure with Azure template

To deploy container registries that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `ContainerRegistryLoginEvents` and `ContainerRegistryRepositoryEvents` categories or `audit` category group or `allLogs` category group.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2023-11-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium"
  },
  "properties": {
    "adminUserEnabled": false,
    "policies": {
      "quarantinePolicy": {
        "status": "enabled"
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Insights/diagnosticSettings",
      "apiVersion": "2021-05-01-preview",
      "scope": "[format('Microsoft.ContainerRegistry/registries/{0}', parameters('name'))]",
      "name": "logs",
      "properties": {
        "workspaceId": "[parameters('workspaceId')]",
        "logs": [
          {
            "category": "ContainerRegistryLoginEvents",
            "enabled": true
          },
          {
            "category": "ContainerRegistryRepositoryEvents",
            "enabled": true
          }
        ]
      },
      "dependsOn": [
        "[parameters('name')]"
      ]
    }
  ]
}
```

### Configure with Bicep

To deploy container registries that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `ContainerRegistryLoginEvents` and `ContainerRegistryRepositoryEvents` categories or `audit` category group or `allLogs` category group.

For example:

```bicep
resource registry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
    }
  }
}

resource logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'logs'
  scope: registry
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
      }
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
      }
    ]
  }
}
```

Alternatively, you can use category groups:

```bicep
resource logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'logs'
  scope: registry
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
  }
}
```

## LINKS

- [SE:10 Monitoring and threat detection](https://learn.microsoft.com/azure/well-architected/security/monitor-threats)
- [LT-4: Enable logging for security investigation](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#lt-4-enable-logging-for-security-investigation)
- [Monitor Azure Container Registry](https://learn.microsoft.com/azure/container-registry/monitor-container-registry)
- [Container Registry resource logs](https://learn.microsoft.com/azure/container-registry/monitor-container-registry-reference#resource-logs)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)

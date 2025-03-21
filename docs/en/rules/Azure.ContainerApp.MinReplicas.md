---
reviewed: 2024-04-02
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Container App
resourceType: Microsoft.App/containerApps
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.MinReplicas/
---

# Use a minimum number of replicas

## SYNOPSIS

Use multiple replicas to remove a single point of failure.

## DESCRIPTION

When a Container App is deployed Azure create one or more instances or replicas of the application.
The number of replicas is configurable and can be automatically scaled up or down based on demand using scaling rules.

When a single instance of the application is deployed, in the event of a failure Azure will replace the instance.
However, this can lead to downtime while the instance is replaced with this single point of failure.

To ensure that the application is highly available, it is recommended to configure a minimum number of replicas.
The minimum number of replicas required will depend on the criticality of the application and the expected demand.

For a production application, consider configuring a minimum of two (2) replicas.
When zone redundancy is configured, use a minimum of three (3) replicas to spread the replicas across all availability zones.

## RECOMMENDATION

Consider configuring a minimum number of replicas for the Container App to remove a single point of failure on a single instance.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set the `properties.template.scale.minReplicas` property to a minimum of `2`.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2024-03-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "environmentId": "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]",
    "template": {
      "revisionSuffix": "[parameters('revision')]",
      "containers": "[variables('containers')]",
      "scale": {
        "minReplicas": 2
      }
    },
    "configuration": {
      "ingress": {
        "allowInsecure": false,
        "external": false,
        "ipSecurityRestrictions": "[variables('ipSecurityRestrictions')]",
        "stickySessions": {
          "affinity": "none"
        }
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

- Set the `properties.template.scale.minReplicas` property to a minimum of `2`.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerEnv.id
    template: {
      revisionSuffix: revision
      containers: containers
      scale: {
        minReplicas: 2
      }
    }
    configuration: {
      ingress: {
        allowInsecure: false
        external: false
        ipSecurityRestrictions: ipSecurityRestrictions
        stickySessions: {
          affinity: 'none'
        }
      }
    }
  }
}
```

<!-- external:avm avm/res/app/container-app:0.11.0 scaleMinReplicas -->

### Configure with Azure CLI

```bash
az containerapp update -n '<name>' -g '<resource_group>' --min-replicas 2 --max-replicas 10
```

### Configure with Azure PowerShell

```powershell
Update-AzContainerApp -Name '<name>' -ResourceGroupName '<resource_group>' -ScaleMinReplica 2 -ScaleMaxReplica 10
```

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Reliability in Azure Container Apps](https://learn.microsoft.com/azure/reliability/reliability-azure-container-apps#availability-zone-support)
- [Set scaling rules in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/scale-app)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps)

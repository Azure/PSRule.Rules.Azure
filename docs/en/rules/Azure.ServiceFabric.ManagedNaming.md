---
reviewed: 2025-11-16
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Service Fabric
resourceType: Microsoft.ServiceFabric/managedClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceFabric.ManagedNaming/
---

# Service Fabric managed cluster resources must use standard naming

## SYNOPSIS

Service Fabric managed cluster resources without a standard naming convention may be difficult to identify and manage.

## DESCRIPTION

An effective naming convention allows operators to quickly identify resources, related systems, and their purpose.
Identifying resources easily is important to improve operational efficiency, reduce the time to respond to incidents,
and minimize the risk of human error.

Some of the benefits of using standardized tagging and naming conventions are:

- They provide consistency and clarity for resource identification and discovery across the Azure Portal, CLIs, and APIs.
- They enable filtering and grouping of resources for billing, monitoring, security, and compliance purposes.
- They support resource lifecycle management, such as provisioning, decommissioning, backup, and recovery.

For example, if you come upon a security incident, it's critical to quickly identify affected systems,
the functions that those systems support, and the potential business impact.

For Service Fabric managed cluster, the Cloud Adoption Framework (CAF) recommends using the `sfmc-` prefix.

Requirements for Service Fabric managed cluster resource names:

- Between 4 and 23 characters long.
- Can include alphanumeric characters, hyphens, underscores, and periods (restrictions vary by resource type).
- Resource names must be unique within their scope.

## RECOMMENDATION

Consider creating Service Fabric managed cluster resources with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy managed clusters that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(4)
@maxLength(23)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource managed 'Microsoft.ServiceFabric/managedClusters@2024-04-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    azureActiveDirectory: {
      clientApplication: clientApplication
      clusterApplication: clusterApplication
      tenantId: tenantId
    }
    dnsName: toLower(name)
    adminUserName: adminUsername
    clientConnectionPort: 19000
    httpGatewayConnectionPort: 19080
    clients: [
      {
        isAdmin: true
        thumbprint: certificateThumbprint
      }
    ]
    loadBalancingRules: [
      {
        frontendPort: 8080
        backendPort: 8080
        protocol: 'tcp'
        probeProtocol: 'https'
      }
    ]
  }
}

```

### Configure with Azure template

To deploy managed clusters that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 4,
      "maxLength": 23,
      "metadata": {
        "description": "The name of the resource."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ServiceFabric/managedClusters",
      "apiVersion": "2024-04-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "Standard"
      },
      "properties": {
        "azureActiveDirectory": {
          "clientApplication": "[parameters('clientApplication')]",
          "clusterApplication": "[parameters('clusterApplication')]",
          "tenantId": "[parameters('tenantId')]"
        },
        "dnsName": "[toLower(parameters('name'))]",
        "adminUserName": "[parameters('adminUsername')]",
        "clientConnectionPort": 19000,
        "httpGatewayConnectionPort": 19080,
        "clients": [
          {
            "isAdmin": true,
            "thumbprint": "[parameters('certificateThumbprint')]"
          }
        ],
        "loadBalancingRules": [
          {
            "frontendPort": 8080,
            "backendPort": 8080,
            "protocol": "tcp",
            "probeProtocol": "https"
          }
        ]
      }
    }
  ]
}
```

## NOTES

This rule does not check if Service Fabric managed cluster resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_SERVICE_FABRIC_MANAGED_CLUSTER_NAME_FORMAT -->

To configure this rule set the `AZURE_SERVICE_FABRIC_MANAGED_CLUSTER_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_SERVICE_FABRIC_MANAGED_CLUSTER_NAME_FORMAT: '^sfmc-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.servicefabric/managedclusters)

---
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Service Fabric
resourceType: Microsoft.ServiceFabric/clusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceFabric.AAD/
---

# Use Entra ID authentication with Service Fabric clusters

## SYNOPSIS

Use Entra ID client authentication for Service Fabric clusters.

## DESCRIPTION

When deploying Service Fabric clusters on Azure,
Entra ID (previously known as Azure AD) can optionally be used to secure management endpoints.
If configured, client authentication (client-to-node security) uses Entra ID.
Additionally Azure Role-based Access Control (RBAC) can be used to delegate cluster access.

For Service Fabric clusters running on Azure, Entra ID is recommended to secure access to management endpoints.

## RECOMMENDATION

Consider enabling Entra ID client authentication for Service Fabric clusters.

## EXAMPLES

### Configure with Bicep

To deploy clusters that pass this rule:

- steps

For example:

```bicep
resource cluster 'Microsoft.ServiceFabric/clusters@2023-11-01-preview' = {
  name: name
  location: location
  properties: {
    azureActiveDirectory: {
      clientApplication: clientApplication
      clusterApplication: clusterApplication
      tenantId: tenantId
    }
    certificate: {
      thumbprint: certificateThumbprint
      x509StoreName: 'My'
    }
    diagnosticsStorageAccountConfig: {
      blobEndpoint: storageAccount.properties.primaryEndpoints.blob
      protectedAccountKeyName: 'StorageAccountKey1'
      queueEndpoint: storageAccount.properties.primaryEndpoints.queue
      storageAccountName: storageAccount.name
      tableEndpoint: storageAccount.properties.primaryEndpoints.table
    }
    fabricSettings: [
      {
        parameters: [
          {
            name: 'ClusterProtectionLevel'
            value: 'EncryptAndSign'
          }
        ]
        name: 'Security'
      }
    ]
    managementEndpoint: endpointUri
    nodeTypes: []
    reliabilityLevel: 'Silver'
    upgradeMode: 'Automatic'
    vmImage: 'Windows'
  }
}
```

### Configure with Azure template

To deploy clusters that pass this rule:

- steps

For example:

```json
{
  "type": "Microsoft.ServiceFabric/clusters",
  "apiVersion": "2023-11-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "azureActiveDirectory": {
      "clientApplication": "[parameters('clientApplication')]",
      "clusterApplication": "[parameters('clusterApplication')]",
      "tenantId": "[parameters('tenantId')]"
    },
    "certificate": {
      "thumbprint": "[parameters('certificateThumbprint')]",
      "x509StoreName": "My"
    },
    "diagnosticsStorageAccountConfig": {
      "blobEndpoint": "[reference(resourceId('Microsoft.Storage/storageAccounts', 'storage1'), '2021-01-01').primaryEndpoints.blob]",
      "protectedAccountKeyName": "StorageAccountKey1",
      "queueEndpoint": "[reference(resourceId('Microsoft.Storage/storageAccounts', 'storage1'), '2021-01-01').primaryEndpoints.queue]",
      "storageAccountName": "storage1",
      "tableEndpoint": "[reference(resourceId('Microsoft.Storage/storageAccounts', 'storage1'), '2021-01-01').primaryEndpoints.table]"
    },
    "fabricSettings": [
      {
        "parameters": [
          {
            "name": "ClusterProtectionLevel",
            "value": "EncryptAndSign"
          }
        ],
        "name": "Security"
      }
    ],
    "managementEndpoint": "[parameters('endpointUri')]",
    "nodeTypes": [],
    "reliabilityLevel": "Silver",
    "upgradeMode": "Automatic",
    "vmImage": "Windows"
  }
}
```

## NOTES

For Linux clusters, Entra ID authentication must be configured at cluster creation time.
Windows cluster can be updated to support Entra ID authentication after initial deployment.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Security recommendations](https://learn.microsoft.com/azure/service-fabric/service-fabric-cluster-security#security-recommendations)
- [Set up Microsoft Entra ID for client authentication](https://learn.microsoft.com/azure/service-fabric/service-fabric-cluster-creation-setup-aad)
- [Configure Azure Active Directory Authentication for Existing Cluster](https://github.com/Azure/Service-Fabric-Troubleshooting-Guides/blob/master/Security/Configure%20Azure%20Active%20Directory%20Authentication%20for%20Existing%20Cluster.md)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.servicefabric/clusters)

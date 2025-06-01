---
reviewed: 2025-06-02
severity: Important
pillar: Security
category: SE:07 Encryption
resource: Service Fabric
resourceType: Microsoft.ServiceFabric/clusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceFabric.ProtectionLevel/
---

# Service Fabric Cluster allows unencrypted node to node communication

## SYNOPSIS

Node to node communication that is not signed and encrypted may be susceptible to man-in-the-middle attacks.

## DESCRIPTION

Service Fabric provides three levels of protection (None, Sign, and EncryptAndSign) for node-to-node communication.
When configured for signing and encryption the primary cluster certificate is used to sign and encrypt all node-to-node messages.
Node-to-node security helps secure communication between the VMs or computers in a cluster.

## RECOMMENDATION

Consider configuring the cluster protection level to encrypt and sign all node-to-node communication.

## EXAMPLES

### Configure with Bicep

To deploy clusters that pass this rule:

- Add the `Security` fabric setting to the `properties.fabricSettings` property.
- Set the `ClusterProtectionLevel` parameter to `EncryptAndSign`.

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

- Add the `Security` fabric setting to the `properties.fabricSettings` property.
- Set the `ClusterProtectionLevel` parameter to `EncryptAndSign`.

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

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [Service Fabric cluster security scenarios](https://learn.microsoft.com/azure/service-fabric/service-fabric-cluster-security)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.servicefabric/clusters#settingsparameterdescription)

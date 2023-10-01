---
severity: Awareness
pillar: Reliability
category: Reliability design principles
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.Storage/
---

# Persistant storage

## SYNOPSIS

Use of Azure Files volume mounts to persistent storage container data.

## DESCRIPTION

Container apps allows you to use different types of storage. This can be achieved by using volume mounts.

There are considerations to be taken, whether persistent storage is suitable for your app or if non-persistent storage is suitable.
Apps may require no storage.

By default all files created inside a container are stored on a writable container layer.

Some considerations when using container file system storage:

- The data doesn’t persist when that container no longer exists, and it can be difficult to get the data out of the container if another process needs it.
- There are no capacity guarantees. The available storage depends on the amount of disk space available in the container.

Usage examples for this can be a stateless web API or a single page application (that just calls APIs).

Some considerations when using storage volume mounts:

- Ephemeral volume
  - Files are persisted for the lifetime of the replica.
    - If a container in a replica restarts, the files in the volume remain.
  - Any containers in the replica can mount the same volume.
  - A container can mount multiple ephemeral volumes.
- Azure Files volume
  - Files written under the mount location are persisted to the file share.
  - Files in the share are available via the mount location.
  - Multiple containers can mount the same file share, including ones that are in another replica, revision, or container app.
  - All containers that mount the share can access files written by any other container or method.
  - More than one Azure Files volume can be mounted in a single container.

Usage examples for this can be a main app container that write log files that are processed by a sidecar container or writing files to a file share to make data accessible by other systems.

## RECOMMENDATION

Consider using Azure File volume mounts to persistent storage across containers and replicas.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Configure the `properties.template.volumes` array to define a volume or several volumes.
- For each volume use the `storageType` of `AzureFile`.
- For each container in the template that you want to mount storage, define a volume mount in the `properties.template.containers.volumeMounts` array.

For example with an Azure Files volume:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2022-10-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned",
    "userAssignedIdentities": {}
  },
  "properties": {
    "environmentId": "[parameters('environmentId')]",
    "template": {
      "revisionSuffix": "",
      "containers": [
        {
          "image": "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest",
          "name": "simple-hello-world-container",
          "resources": {
            "cpu": "[json('.25')]",
            "memory": ".5Gi"
          },
          "volumeMounts": [
            {
              "mountPath": "/myfiles",
              "volumeName": "azure-files-volume"
            }
          ]
        }
      ],
      "scale": {
        "minReplicas": 1,
        "maxReplicas": 3
      },
      "volumes": [
        {
          "name": "azure-files-volume",
          "storageType": "AzureFile",
          "storageName": "myazurefiles"
        }
      ]
    }
  }
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Configure the `properties.template.volumes` array to define a volume or several volumes.
- For each volume use the `storageType` of `AzureFile`.
- For each container in the template that you want to mount storage, define a volume mount in the `properties.template.containers.volumeMounts` array.

For example with an Azure Files volume:

```bicep
resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
    userAssignedIdentities: {}
  }
  properties: {
    environmentId: environmentId
    template: {
      revisionSuffix: ''
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: 'simple-hello-world-container'
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
          volumeMounts: [
            {
              mountPath: '/myfiles'
              volumeName: 'azure-files-volume'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
      volumes: [
        {
          name: 'azure-files-volume'
          storageType: 'AzureFile'
          storageName: 'myazurefiles'
        }
      ]
    }
  }
}
```

## NOTES

To enable Azure Files storage, a storage definition must be defined in the Container Apps Environment.

## LINKS

- [Reliability design principles](https://learn.microsoft.com/azure/architecture/framework/resiliency/principles#design-for-scale-out)
- [Use storage mounts in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/storage-mounts)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#volumemount)

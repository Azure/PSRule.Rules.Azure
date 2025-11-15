// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(2)
@maxLength(32)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The name of a Log Analytics workspace')
param workspaceId string

@description('The resource ID of a VNET subnet.')
param subnetId string

@description('The revision of the container app.')
param revision string

@description('The name of the workload profile to use for the job.')
param workloadProfileName string

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: split(workspaceId, '/')[8]
}

var containers = [
  {
    name: 'simple-hello-world-container'
    image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
    resources: {
      cpu: json('0.25')
      memory: '.5Gi'
    }
  }
]

var ipSecurityRestrictions = [
  {
    action: 'Allow'
    description: 'Allowed IP address range'
    ipAddressRange: '10.1.1.1/32'
    name: 'ClientIPAddress_1'
  }
  {
    action: 'Allow'
    description: 'Allowed IP address range'
    ipAddressRange: '10.1.2.1/32'
    name: 'ClientIPAddress_2'
  }
]

// An example App Environment configured with a consumption workload profile.
resource containerEnv 'Microsoft.App/managedEnvironments@2025-01-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace.properties.customerId
        sharedKey: workspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: true
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    vnetConfiguration: {
      infrastructureSubnetId: subnetId
      internal: true
    }
  }
}

// An example Container App using a minimum of 2 replicas.
resource containerApp 'Microsoft.App/containerApps@2025-01-01' = {
  name: name
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

// An example Container App with IP security restrictions.
resource containerAppWithSecurity 'Microsoft.App/containerApps@2025-01-01' = {
  name: name
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
        ipSecurityRestrictions: [
          {
            action: 'Allow'
            description: 'Allowed IP address range'
            ipAddressRange: '10.1.1.1/32'
            name: 'ClientIPAddress_1'
          }
          {
            action: 'Allow'
            description: 'Allowed IP address range'
            ipAddressRange: '10.1.2.1/32'
            name: 'ClientIPAddress_2'
          }
        ]
        stickySessions: {
          affinity: 'none'
        }
      }
    }
  }
}

// An example Container App Job using a workload profile.
resource job 'Microsoft.App/jobs@2025-01-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerEnv.id
    template: {
      containers: containers
    }
    workloadProfileName: workloadProfileName
    configuration: {
      replicaTimeout: 300
      triggerType: 'Manual'
      manualTriggerConfig: {}
    }
  }
}

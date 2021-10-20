// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

// Define parameters

@description('The name of the AKS cluster.')
param clusterName string

@metadata({
  description: 'Optional. The Azure region to deploy to.'
  strongType: 'location'
  example: 'EastUS'
  ignore: true
})
param location string = resourceGroup().location

@description('The name of the user assigned identity to used for cluster control plane.')
param identityName string

@description('A DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GiB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
param osDiskSizeGB int = 32

@description('The size of cluster VM instances.')
param systemVMSize string = 'Standard_D2s_v3'

@metadata({
  description: 'The minimum number of agent nodes for the system pool.'
  example: 3
})
@minValue(1)
@maxValue(50)
param systemPoolMin int

@metadata({
  description: 'The maximum number of agent nodes for the system pool.'
  example: 3
})
@minValue(1)
@maxValue(50)
param systemPoolMax int = 3

@description('The version of Kubernetes.')
param kubernetesVersion string = '1.19.7'

@description('Maximum number of pods that can run on nodes in the system pool.')
@minValue(30)
param systemPoolMaxPods int = 50

@metadata({
  description: 'Specify the resource id of the OMS workspace.'
  strongType: 'Microsoft.OperationalInsights/workspaces'
})
param workspaceId string

@metadata({
  description: 'The resource Id for the virtual network where the cluster and ACI will be deployed into.'
  strongType: 'Microsoft.Network/virtualNetworks'
})
param vnetId string

@description('The name of the subnet do deploy cluster resources.')
param systemPoolSubnet string

@description('Determines if the Key Vault provider automatically rotates secrets.')
param useSecretRotation bool = false

@description('Determines if Open Service Mesh for Kubernetes is enabled.')
param useOpenServiceMesh bool = false

@description('The object Ids of groups that will be added with the cluster admin role.')
param clusterAdmins array = []

@metadata({
  description: 'User cluster pools.'
  example: [
    {
      name: ''
      priority: 'Regular'
      osType: 'Linux'
      minCount: 0
      maxCount: 2
      vmSize: 'Standard_D2s_v3'
    }
  ]
})
param pools array = []

@description('Determine if cluster upgrades are automatically applied.')
@allowed([
  'none'
  'rapid'
  'stable'
  'patch'
])
param upgradeChannel string = 'none'

@metadata({
  description: 'Tags to apply to the resource.'
  example: {
    service: 'container-platform'
    env: 'prod'
  }
})
param tags object

// Define variables

var serviceCidr = '192.168.0.0/16'
var dnsServiceIP = '192.168.0.4'
var dockerBridgeCidr = '172.17.0.1/16'
var clusterSubnetId = '${vnetId}/subnets/${systemPoolSubnet}'

// Define pools
var allPools = union(systemPools, userPools)
var systemPools = [
  {
    name: 'system'
    osDiskSizeGB: osDiskSizeGB
    count: systemPoolMin
    minCount: systemPoolMin
    maxCount: systemPoolMax
    enableAutoScaling: true
    maxPods: systemPoolMaxPods
    vmSize: systemVMSize
    osType: 'Linux'
    type: 'VirtualMachineScaleSets'
    vnetSubnetID: clusterSubnetId
    mode: 'System'
    osDiskType: 'Ephemeral'
    scaleSetPriority: 'Regular'
  }
]
var userPools = [for i in range(0, length(pools)): {
  name: pools[i].name
  osDiskSizeGB: osDiskSizeGB
  count: pools[i].minCount
  minCount: pools[i].minCount
  maxCount: pools[i].maxCount
  enableAutoScaling: true
  maxPods: pools[i].maxPods
  vmSize: pools[i].vmSize
  osType: pools[i].osType
  type: 'VirtualMachineScaleSets'
  vnetSubnetID: clusterSubnetId
  mode: 'User'
  osDiskType: 'Ephemeral'
  scaleSetPriority: pools[i].priority
}]

// Define resources

// Cluster managed identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
  tags: tags
}

// Cluster
resource cluster 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  location: location
  name: clusterName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: allPools
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      adminGroupObjectIDs: clusterAdmins
      tenantID: subscription().tenantId
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: dockerBridgeCidr
    }
    autoUpgradeProfile: {
      upgradeChannel: upgradeChannel
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: false
      }
      azurepolicy: {
        enabled: true
        config: {
          version: 'v2'
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
      }
      kubeDashboard: {
        enabled: false
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: string(useSecretRotation)
        }
      }
      openServiceMesh: {
        enabled: useOpenServiceMesh
      }
    }
  }
  tags: tags
}

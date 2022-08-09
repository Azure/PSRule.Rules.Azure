// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep test cases

@description('The name of the API Management service.')
param name string = 'apim'

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The reply email of the publisher.')
param publisherEmail string = 'noreply@contoso.com'

@description('The display name of the publisher.')
param publisherName string = 'Contoso'

// An example API Management service
resource service_01 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: '${name}-01'
  location: location
  sku: {
    name: 'Premium'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'True'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'False'
    }
  }
}

// An example product
resource product_01 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  parent: service_01
  name: 'product-01'
  properties: {
    displayName: 'Echo'
    description: 'Echo API services for Contoso.'
    approvalRequired: true
    subscriptionRequired: true
  }
}

// An example API Version
resource version 'Microsoft.ApiManagement/service/apiVersionSets@2021-08-01' = {
  parent: service_01
  name: 'version-01'
  properties: {
    displayName: 'Echo API'
    description: 'An echo API service.'
    versioningScheme: 'Segment'
  }
}

// An example API
resource api_01 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: service_01
  name: 'api-01'
  properties: {
    displayName: 'Echo API'
    description: 'An echo API service.'
    path: 'echo'
    serviceUrl: 'https://echo.contoso.com'
    protocols: [
      'https'
    ]
    apiVersion: 'v1'
    apiVersionSetId: version.id
    subscriptionRequired: true
  }
}

// An example API
resource api_02 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'apim-02/api-02'
  properties: {
    displayName: 'Echo API'
    description: 'An echo API service.'
    path: 'echo'
    serviceUrl: 'http://echo.contoso.com'
    protocols: [
      'https'
    ]
    subscriptionRequired: true
  }
}

// An example API
resource api_03 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'apim-03/api-03'
  properties: {
    displayName: 'Echo API'
    description: 'An echo API service.'
    path: 'echo'
    protocols: [
      'https'
    ]
    subscriptionRequired: true
  }
}

// An example API backend
resource backend_01 'Microsoft.ApiManagement/service/backends@2021-08-01' = {
  parent: service_01
  name: 'backend-01'
  properties: {
    title: 'echo'
    description: 'A backend service for the Each API.'
    protocol: 'http'
    url: 'https://echo.contoso.com'
  }
}

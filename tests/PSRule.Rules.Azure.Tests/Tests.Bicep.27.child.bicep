// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param minTLSVersion string?
param corsRules corsRule

type corsRule = {
  allowedHeaders: string[]
  allowedMethods: string[]
  allowedOrigins: string[]
  exposedHeaders: string[]
  maxAgeInSeconds: int
}[]?

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'test'
  #disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: minTLSVersion ?? 'TLS1_2'
  }

  resource blob 'blobServices' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: corsRules ?? []
      }
    }
  }
}

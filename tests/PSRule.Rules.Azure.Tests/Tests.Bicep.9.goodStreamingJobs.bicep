// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@secure()
param secret string

@secure()
param secretFromKeyVault string

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'aStorageAccount'
}

resource goodStreamingJobs 'Microsoft.StreamAnalytics/streamingjobs@2021-10-01-preview' = {
  name: 'goodStreamingJobs'
  properties: {
    inputs: [
      {
        name: 'inputWithSecretPassword'
        properties: {
          type: 'Reference'
          datasource: {
            type: 'Microsoft.Sql/Server/Database'
            properties: {
              password: secret
            } 
          }
        }
      }
      {
        name: 'inputUsingListKeys'
        properties: {
          type: 'Reference'
          datasource: {
            type: 'Microsoft.Sql/Server/Database'
            properties: {
              password: storage.listKeys().keys[0].value
            } 
          }
        }
      }
      {
        name: 'inputUsingKeyVault'
        properties: {
          type: 'Reference'
          datasource: {
            type: 'Microsoft.Sql/Server/Database'
            properties: {
              password: secretFromKeyVault
            } 
          }
        }
      }
    ]
    outputs: [
      {
        name: 'outputWithoutPassword'
        properties: {
        }
      }
    ]
  }
}

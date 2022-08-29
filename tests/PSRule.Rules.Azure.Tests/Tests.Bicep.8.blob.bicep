// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param deleteRetentionPolicy bool = true

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'storage01/default'
  properties: {
    deleteRetentionPolicy: {
      enabled: deleteRetentionPolicy
    }
  }
}

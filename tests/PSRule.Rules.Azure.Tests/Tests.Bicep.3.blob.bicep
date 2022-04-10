// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param storageAccountName string

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  name: '${storageAccountName}/default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

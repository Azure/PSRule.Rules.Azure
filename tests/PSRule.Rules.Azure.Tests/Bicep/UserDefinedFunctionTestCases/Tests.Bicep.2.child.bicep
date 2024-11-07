// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

param name string = customNamingFunction('sa', 1)

import { customNamingFunction } from './Tests.Bicep.2.fn.bicep'

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

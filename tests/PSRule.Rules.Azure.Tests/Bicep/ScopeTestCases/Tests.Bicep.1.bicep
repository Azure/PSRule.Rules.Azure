// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'tenant'

resource mg_2 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-02'
  properties: {
    displayName: 'mg-02'
    details: {
      parent: mg_1
    }
  }
}

resource mg_1 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: 'mg-01'
  properties: {
    displayName: 'mg-01'
  }
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'mi'
  location: 'eastus'
}

output clientId string = mi.properties.clientId

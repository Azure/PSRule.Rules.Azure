// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string
param location string
param tags object

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

output id string = id.id

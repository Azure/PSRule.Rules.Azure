// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'subscription'

param name string
param location string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
}

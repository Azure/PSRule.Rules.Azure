// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param name string

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: name
}

output networkSecurityGroupResourceId string = nsg.id

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Community provided sample from: https://github.com/Azure/PSRule.Rules.Azure/issues/2578

param subnetNum string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: 'vnet/subnet${subnetNum}'
}

output subnetResourceId string = subnet.id

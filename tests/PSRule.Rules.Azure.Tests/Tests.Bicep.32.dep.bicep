// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Community provided sample from: https://github.com/Azure/PSRule.Rules.Azure/issues/2578

param subnetResourceId string

var splitSubnetId = split(subnetResourceId, '/')

resource tags 'Microsoft.Resources/tags@2022-09-01' = {
  scope: resourceGroup()
  name: 'default'
  properties: {
    tags: {
      subnetId: splitSubnetId[8]
      deployment: deployment().name
    }
  }
}

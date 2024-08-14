// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'managementGroup'

param subscriptionId string

module deploySub './Tests.Bicep.31.child4.bicep' = {
  name: 'child4'
  scope: subscription(subscriptionId)
}

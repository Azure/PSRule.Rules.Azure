// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'tenant'

param managementGroupId string
param subscriptionId string

resource customSubscriptionPlacement 'Microsoft.Management/managementGroups/subscriptions@2023-04-01' = {
  name: '${last(split(managementGroupId, '/'))}/${subscriptionId}'
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'tenant'

param managementGroups managementGroup[]

type managementGroup = {
  id: string
  subscriptionId: string
}

module customSubscriptionPlacement './Tests.Bicep.3.child3.bicep' = [
  for (place, index) in managementGroups: {
    name: 'placement-${uniqueString(place.id)}${index}'
    params: {
      managementGroupId: place.id
      subscriptionId: place.subscriptionId
    }
  }
]

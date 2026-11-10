// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param grants array

module assignment './Tests.Bicep.46.grant.bicep' = [
  for grant in grants: {
    name: 'ra-${uniqueString(grant.name, grant.principalId)}'
    params: {
      principalId: grant.principalId
    }
  }
]

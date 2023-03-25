// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param phases object
param location string

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = [for item in items(phases): {
  name: item.value.workspace
  location: location
}]

output ids array = [for (Phase, index) in items(phases): {
  id: workspace[index].id
}]

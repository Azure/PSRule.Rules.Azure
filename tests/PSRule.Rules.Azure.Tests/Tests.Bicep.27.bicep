// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

module child 'Tests.Bicep.27.child.bicep' = {
  name: 'child'
}

output childFromFor string = child.outputs.fromFor

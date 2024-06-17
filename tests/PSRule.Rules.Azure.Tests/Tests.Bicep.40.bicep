// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2935

module child './Tests.Bicep.40.child.bicep' = {
  name: 'child'
  params: {
    name: 'child'
  }
}

output items array = union([child.outputs.id, child.outputs], [])

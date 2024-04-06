// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2801.

module child 'Tests.Bicep.36.child.bicep' = {
  name: 'child'
}

output items array = [
  {
    items: child.outputs.items
  }
]

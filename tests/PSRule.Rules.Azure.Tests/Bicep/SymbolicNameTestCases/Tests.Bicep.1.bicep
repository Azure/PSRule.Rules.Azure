// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2922
// Based on work contributed by @GABRIELNGBTUC

module child_loop './Tests.Bicep.1.child.bicep' = [
  for (item, index) in range(0, 2): {
    name: 'deploy-${index}'
    params: {
      index: index
    }
  }
]

output items array = map(child_loop, item => item.outputs.childValue)
output itemsAsString string[] = map(child_loop, item => item.outputs.childValue)

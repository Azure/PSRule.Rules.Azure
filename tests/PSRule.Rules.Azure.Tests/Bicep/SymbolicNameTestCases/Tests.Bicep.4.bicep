// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3129
// Contributed by @CharlesToniolo

var names = [
  'example1-webapp'
  'example2-webapp'
]

resource app 'Microsoft.Web/sites@2022-09-01' existing = [
  for name in names: {
    name: name
  }
]

output ids array = [for i in range(0, length(names)): app[i].id]

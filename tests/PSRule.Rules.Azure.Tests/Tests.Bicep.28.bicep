// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

module child './Tests.Bicep.28.child.bicep' = {
  name: 'child'
  params: {
    value: 't1'
  }
}

output outValue string = child.outputs.outValue

output hello string = child.outputs.hello

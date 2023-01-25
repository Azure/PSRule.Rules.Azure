// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param value1 array = []
param value2 array = []

var ip = '10.0.0.4'

module child 'Tests.Bicep.11.child.bicep' = {
  name: 'child1'
  params: {
    value3: value1
    value4: value2
    staticIP: ip
  }
}

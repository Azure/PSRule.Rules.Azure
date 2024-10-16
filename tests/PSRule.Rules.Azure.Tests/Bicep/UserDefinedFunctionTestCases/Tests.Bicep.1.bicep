// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3120

import * as child from './Tests.Bicep.1.child.bicep'

var v1 = []
var v2 = [
  2
]

func getV3() array => union(v1, v2)

output o1 array = getV3()
output o2 array = child.getV3()
output o3 array = union(child.v1, child.v2)
output o4 array = union(v2, child.v2)
output o5 array = child.getV4()

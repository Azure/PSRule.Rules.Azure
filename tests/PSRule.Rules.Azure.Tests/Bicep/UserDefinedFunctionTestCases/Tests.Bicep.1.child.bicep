// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@export()
var v1 = []

@export()
var v2 = [
  1
]

@export()
func getV3() array => union(v1, v2)

import * as child2 from './Tests.Bicep.1.child2.bicep'

@export()
func getV4() array => union(child2.v1, child2.v2)

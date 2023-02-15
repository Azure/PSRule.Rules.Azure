// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Tests for custom types

param props custom = {
  name: 'abc'
  properties: {
    enabled: true
    settings: []
  }
}

type keyValue = [
  {
    name: string
    value: int
  }
  {
    name: string
    value: string
  }
]

type enabled = true | false

type custom = {
  name: string
  properties: {
    enabled: enabled
    settings: keyValue
  }
}


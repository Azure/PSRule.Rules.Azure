// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Tests for custom types

#disable-next-line no-unused-params
param props custom = {
  name: 'abc'
  properties: {
    enabled: true
    settings: [
      {
        name: 'key1'
        value: 1
      }
      {
        name: 'key2'
        value: 'value2'
      }
    ]
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

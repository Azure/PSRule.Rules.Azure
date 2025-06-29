// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@secure()
#disable-next-line secure-parameter-default
param value string = 'abc'

resource configValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-06-01' = {
  name: 'store/testInsecure'
  properties: {
    value: value
    contentType: 'text/plain'
  }
}

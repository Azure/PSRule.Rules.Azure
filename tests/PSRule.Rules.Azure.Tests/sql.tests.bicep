// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the resource.')
param name string = 'sql'

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource server01 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: 'sql-${name}-01'
  location: location
}

resource database01 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: server01
  name: 'sqldb-${name}-01'
  location: location
}

resource database02 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: server01
  name: 'sqldb-${name}-02'
  location: location

  resource tde 'transparentDataEncryption@2021-11-01-preview' = {
    name: 'current'
    properties: {
      state: 'Disabled'
    }
  }
}

resource database03 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: server01
  name: 'sqldb-${name}-03'
  location: location
}

resource tde 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01-preview' = {
  parent: database03
  name: 'current'
  properties: {
    state: 'Disabled'
  }
}

resource tde2 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01-preview' = {
  name: 'server01/db01/current'
  properties: {
    state: 'Disabled'
  }
}

resource tde3 'Microsoft.Sql/servers/databases/transparentDataEncryption@2014-04-01' = {
  name: 'server01/db02/current'
  properties: {
    status: 'Disabled'
  }
}

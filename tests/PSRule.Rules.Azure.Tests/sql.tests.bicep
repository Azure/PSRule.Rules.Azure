// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the resource.')
param name string = 'sql'

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource server_01 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: 'sql-${name}-01'
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'sql-admins'
      sid: '00000000-0000-0000-0000-000000000000'
    }
  }
}

resource server_02 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: 'sql-${name}-02'
  location: location
}

resource server_03 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: 'sql-${name}-03'
  location: location
}

resource aadAuth_01 'Microsoft.Sql/servers/administrators@2021-11-01-preview' = {
  parent: server_03
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'sql-admins'
    sid: '00000000-0000-0000-0000-000000000000'
  }
}

resource database01 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: server_01
  name: 'sqldb-${name}-01'
  location: location
}

resource database02 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: server_01
  name: 'sqldb-${name}-02'
  location: location

  resource tde 'transparentDataEncryption@2021-11-01-preview' = {
    name: 'current'
    properties: {
      state: 'Disabled'
    }
  }
}

resource database_03 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: server_01
  name: 'sqldb-${name}-03'
  location: location
}

resource tde_01 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01-preview' = {
  parent: database_03
  name: 'current'
  properties: {
    state: 'Disabled'
  }
}

resource tde_02 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-11-01-preview' = {
  name: 'server01/db01/current'
  properties: {
    state: 'Disabled'
  }
}

resource tde_03 'Microsoft.Sql/servers/databases/transparentDataEncryption@2014-04-01' = {
  name: 'server01/db02/current'
  properties: {
    status: 'Disabled'
  }
}

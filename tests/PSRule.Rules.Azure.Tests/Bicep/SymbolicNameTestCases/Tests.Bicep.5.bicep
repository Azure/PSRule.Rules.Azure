// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3146
// Contributed by @riosengineer

param rgName string = 'rg-test'
param location string = 'eastus'
param sqlServerName string = 's1'
param sqlAdministrators object = {
  azureADOnlyAuthentication: true
  login: 'group1'
  sid: 'sid'
  principalType: 'Group'
}
param sqlDatabase object = {
  name: 'sqldb'
  tier: 'Basic'
  sku: 'Basic'
  maxSizeBytes: 2147483648
  collation: 'SQL_Latin1_General_CP1_CI_AS'
}

// Azure SQL DB
module sqlDb 'br/public:avm/res/sql/server:0.8.0' = {
  name: 'abc'
  scope: resourceGroup(rgName)
  params: {
    name: sqlServerName
    location: location
    minimalTlsVersion: '1.2'
    managedIdentities: {
      systemAssigned: true
    }
    privateEndpoints: [
      {
        name: 'pe'
        customNetworkInterfaceName: 'pe-sql-nic'
        subnetResourceId: ''
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: ''
            }
          ]
        }
      }
    ]
    publicNetworkAccess: 'Disabled'
    securityAlertPolicies: [
      {
        name: 'Default'
        state: 'Enabled'
        emailAccountAdmins: true
      }
    ]
    administrators: {
      azureADOnlyAuthentication: sqlAdministrators.azureADOnlyAuthentication
      login: sqlAdministrators.login
      sid: sqlAdministrators.sid
      principalType: sqlAdministrators.principalType
    }
    databases: [
      {
        name: sqlDatabase.name
        collation: sqlDatabase.collation
        maxSizeBytes: sqlDatabase.maxSizeBytes
        skuTier: sqlDatabase.tier
        skuName: sqlDatabase.sku
      }
    ]
  }
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param appInsightsName string = 'app-insights'

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}
resource goodSecretReference 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'keyvault/good'
  properties: {
    value: appInsights.properties.InstrumentationKey
  }
}

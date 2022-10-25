// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Disable linter rule
#disable-next-line secure-secrets-in-params
param notSecret string

resource badStreamingJobs 'Microsoft.StreamAnalytics/streamingjobs@2021-10-01-preview' = {
  name: 'badStreamingJobs'
  properties: {
    inputs: [
      {
        name: 'inputWithoutSecretPassword'
        properties: {
          type: 'Reference'
          datasource: {
            type: 'Microsoft.Sql/Server/Database'
            properties: {
              password: notSecret
            } 
          }
        }
      }
    ]
    outputs: [
      {
        name: 'outputWithoutSecretPassword'
        properties: {
          datasource: {
            type: 'Microsoft.DBForPostgreSQL/servers/databases'
            properties: {
              password: notSecret
            }
          }
        }
      }
    ]
  }
}

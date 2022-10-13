// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@secure()
param secret string

resource goodStreamingJobs 'Microsoft.StreamAnalytics/streamingjobs@2021-10-01-preview' = {
  name: 'goodStreamingJobs'
  properties: {
    inputs: [
      {
        name: 'inputWithSecretPassword'
        properties: {
          type: 'Reference'
          datasource: {
            type: 'Microsoft.Sql/Server/Database'
            properties: {
              password: secret
            } 
          }
        }
      }
    ]
    outputs: [
      {
        name: 'outputWithoutPassword'
        properties: {
        }
      }
    ]
  }
}

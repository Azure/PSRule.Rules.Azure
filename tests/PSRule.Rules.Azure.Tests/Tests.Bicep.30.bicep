// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Community provided sample from: https://github.com/Azure/PSRule.Rules.Azure/issues/2531

var stringToCheck = 'abcd'
var stringToFind = 'bc'
var doesNotContain = !(contains(stringToCheck, stringToFind))
var doesContain = contains(stringToCheck, stringToFind)
var indexOfSubstring = indexOf(stringToCheck, stringToFind)

#disable-next-line BCP081 no-deployments-resources
resource taskDeployment 'Microsoft.Resources/deployments@2020-10-01' = {
  name: 'name'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: [
        {
          apiVersion: '2019-12-01'
          type: 'Microsoft.ManagedIdentity/userAssignedIdentities'
          name: 'test'
          properties: {
            doesNotContain: doesNotContain
            doesContain: doesContain
            indexOfSubstring: indexOfSubstring
            stringToCheck: stringToCheck
            stringToFind: stringToFind
          }
        }
      ]
    }
  }
}

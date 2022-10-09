// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

module secret_good 'Tests.Bicep.9.goodSecret.bicep' = {
  name: 'secret_good'
  params: {
    secret: ''
  }
}

module secret_bad 'Tests.Bicep.9.badSecret.bicep' = {
  name: 'secret_bad'
  params: {
    notSecret: ''
  }
}

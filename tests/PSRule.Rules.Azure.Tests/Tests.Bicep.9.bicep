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

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: 'aKeyVault'
}

module streaming_jobs_good 'Tests.Bicep.9.goodStreamingJobs.bicep' = {
  name: 'streaming_jobs_good'
  params: {
    secret: ''
    secretFromKeyVault: vault.getSecret('aSecretName')
  }
}

module streaming_jobs_bad 'Tests.Bicep.9.badStreamingJobs.bicep' = {
  name: 'streaming_jobs_bad'
  params: {
    notSecret: ''
  }
}

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

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: 'storageAccountName'
}

module secret_bad2 'Tests.Bicep.9.badSecret.bicep' = {
  name: 'secret_bad2'
  params: {
    notSecret: storage.listKeys().keys[0].value
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

module container_apps_bad 'Tests.Bicep.9.badContainerApps.bicep' = {
  name: 'container_apps_bad'
  params: {
    notSecret: ''
  }
}

module secret_goodreference 'Tests.Bicep.9.goodReference.bicep' = {
  name: 'reference_good'
}

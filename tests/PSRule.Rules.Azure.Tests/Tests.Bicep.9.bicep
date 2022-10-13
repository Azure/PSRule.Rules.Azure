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

module streaming_jobs_good 'Tests.Bicep.9.goodStreamingJobs.bicep' = {
  name: 'streaming_jobs_good'
  params: {
    secret: ''
  }
}

module streaming_jobs_bad 'Tests.Bicep.9.badStreamingJobs.bicep' = {
  name: 'streaming_jobs_bad'
  params: {
    notSecret: ''
  }
}

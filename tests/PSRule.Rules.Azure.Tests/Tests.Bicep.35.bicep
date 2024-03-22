// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2751.

var roles = ['Reader']

module script 'br/public:avm/res/resources/deployment-script:0.1.2' = {
  name: 'script'
  params: {
    kind: 'AzurePowerShell'
    name: toLower('ds-001')
    retentionInterval: 'PT1H'
    azPowerShellVersion: '9.7'
    arguments: ''
    scriptContent: '''
      
    '''
  }
}

module other './Tests.Bicep.35.child.bicep' = [
  for role in roles: {
    name: role
    params: {
      value: script.outputs.outputs[role]
    }
  }
]

output other string = other[0].outputs.value

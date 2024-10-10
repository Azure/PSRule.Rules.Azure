// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3062

extension microsoftGraphV1_0

var appRoleId = 'appRoleId'
var certKey = 'certKey'

resource resourceApp 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: 'ExampleResourceApp'
  displayName: 'Example Resource Application'
  appRoles: [
    {
      id: appRoleId
      allowedMemberTypes: ['User', 'Application']
      description: 'Read access to resource app data'
      displayName: 'ResourceAppData.Read.All'
      value: 'ResourceAppData.Read.All'
      isEnabled: true
    }
  ]
}

resource resourceSp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: resourceApp.appId
}

resource clientApp 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: 'ExampleClientApp'
  displayName: 'Example Client Application'
  keyCredentials: [
    {
      displayName: 'Example Client App Key Credential'
      usage: 'Verify'
      type: 'AsymmetricX509Cert'
      key: certKey
    }
  ]
}

resource clientSp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: clientApp.appId
}

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3123
// Contributed by @CharlesToniolo

var webAppsNames = [
  'example1'
  'example2'
]

resource webApps 'Microsoft.Web/sites@2022-09-01' existing = [
  for webAppName in webAppsNames: {
    name: webAppName
  }
]

#disable-next-line no-unused-existing-resources
resource webAppSettings 'Microsoft.Web/sites/config@2022-09-01' existing = [
  for i in range(0, length(webAppsNames)): {
    name: 'appsettings'
    parent: webApps[i]
  }
]

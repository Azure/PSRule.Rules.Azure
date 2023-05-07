resource apiManagementService 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: 'testdefender'
}

resource defender 'Microsoft.Security/apiCollections@2022-11-20-preview' = {
  name: 'labs-test'
  scope: apiManagementService
}

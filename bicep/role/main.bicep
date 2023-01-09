
param roleGUID string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
param principalId string
param name string = 'default'


@description('the role deffinition is collected')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: roleGUID
}

resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(resourceGroup().id, roleGUID, principalId, name)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output roleID string = roleDefinition.id

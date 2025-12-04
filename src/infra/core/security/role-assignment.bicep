@description('The principal ID to assign the role to')
param principalId string

@description('The role definition ID')
param roleDefinitionId string

@description('The type of principal')
@allowed([
  'ServicePrincipal'
  'User'
  'Group'
])
param principalType string = 'ServicePrincipal'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleDefinitionId, resourceGroup().id)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: principalType
  }
}

@description('The ID of the role assignment')
output id string = roleAssignment.id

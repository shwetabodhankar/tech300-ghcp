@description('The name of the user-assigned managed identity')
param identityName string

@description('Azure region for the resources')
param location string = resourceGroup().location

@description('Tags to apply to the managed identity')
param tags object = {}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: tags
}

@description('The resource ID of the managed identity')
output identityId string = managedIdentity.id

@description('The principal ID of the managed identity')
output principalId string = managedIdentity.properties.principalId

@description('The client ID of the managed identity')
output clientId string = managedIdentity.properties.clientId

@description('The name of the managed identity')
output name string = managedIdentity.name

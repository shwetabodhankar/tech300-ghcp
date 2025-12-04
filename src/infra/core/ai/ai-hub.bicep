@description('The name of the AI Hub')
param hubName string

@description('Azure region for the AI Hub')
param location string = resourceGroup().location

@description('Tags to apply to the AI Hub')
param tags object = {}

@description('The resource ID of the AI Services account')
param aiServicesId string

@description('The resource ID of the storage account')
param storageAccountId string

@description('The resource ID of the Key Vault')
param keyVaultId string

@description('The resource ID of Application Insights')
param applicationInsightsId string

@description('Friendly name for the hub')
param friendlyName string = hubName

@description('Description of the hub')
param description string = 'Azure AI Foundry Hub for ZavaStorefront'

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: hubName
  location: location
  tags: tags
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: friendlyName
    description: description
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightsId
    publicNetworkAccess: 'Enabled'
    v1LegacyMode: false
  }
  
  // AI Services connection
  resource aiServicesConnection 'connections@2024-04-01' = {
    name: '${hubName}-aiservices'
    properties: {
      category: 'AIServices'
      target: reference(aiServicesId, '2023-05-01').endpoint
      authType: 'AAD'
      isSharedToAll: true
      metadata: {
        ApiVersion: '2023-05-01'
        ResourceId: aiServicesId
      }
    }
  }
}

@description('The resource ID of the AI Hub')
output id string = aiHub.id

@description('The name of the AI Hub')
output name string = aiHub.name

@description('The workspace ID of the AI Hub')
output workspaceId string = aiHub.properties.workspaceId

@description('The discovery URL of the AI Hub')
output discoveryUrl string = aiHub.properties.discoveryUrl

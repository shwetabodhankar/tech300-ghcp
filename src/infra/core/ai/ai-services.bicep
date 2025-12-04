@description('The name of the Azure AI Services account')
param aiServicesName string

@description('Azure region for the AI Services')
param location string = resourceGroup().location

@description('Tags to apply to the AI Services')
param tags object = {}

@description('The SKU for AI Services')
param sku string = 'S0'

@description('The kind of AI Services account')
param kind string = 'AIServices'

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServicesName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    customSubDomainName: toLower(aiServicesName)
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

@description('The resource ID of the AI Services account')
output id string = aiServices.id

@description('The name of the AI Services account')
output name string = aiServices.name

@description('The endpoint of the AI Services account')
output endpoint string = aiServices.properties.endpoint

@description('The primary key of the AI Services account')
output key string = aiServices.listKeys().key1

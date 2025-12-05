@description('The name of the App Service Plan')
param planName string

@description('Azure region for the plan')
param location string = resourceGroup().location

@description('Tags to apply to the plan')
param tags object = {}

@description('The SKU for the App Service Plan')
param sku object = {
  name: 'B1'
  tier: 'Basic'
  size: 'B1'
  family: 'B'
  capacity: 1
}

@description('OS type (Linux or Windows)')
@allowed([
  'Linux'
  'Windows'
])
param kind string = 'Linux'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  tags: tags
  sku: sku
  kind: kind
  properties: {
    reserved: kind == 'Linux' ? true : false
    zoneRedundant: false
  }
}

@description('The resource ID of the App Service Plan')
output id string = appServicePlan.id

@description('The name of the App Service Plan')
output name string = appServicePlan.name

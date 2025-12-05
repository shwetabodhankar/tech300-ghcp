@description('The name of the Azure Container Registry')
@minLength(5)
@maxLength(50)
param registryName string

@description('Azure region for the registry')
param location string = resourceGroup().location

@description('Tags to apply to the registry')
param tags object = {}

@description('The SKU of the container registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Enable admin user (should be false for production, use managed identity)')
param adminUserEnabled bool = false

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
  }
}

@description('The resource ID of the container registry')
output id string = containerRegistry.id

@description('The name of the container registry')
output name string = containerRegistry.name

@description('The login server URL')
output loginServer string = containerRegistry.properties.loginServer

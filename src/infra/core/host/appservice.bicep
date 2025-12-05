@description('The name of the App Service')
param appName string

@description('Azure region for the app')
param location string = resourceGroup().location

@description('Tags to apply to the app')
param tags object = {}

@description('The resource ID of the App Service Plan')
param appServicePlanId string

@description('The resource ID of the user-assigned managed identity')
param managedIdentityId string

@description('The login server of the container registry')
param containerRegistryUrl string

@description('The Docker image name and tag')
param dockerImageName string = 'zavastor:latest'

@description('Application Insights connection string')
param applicationInsightsConnectionString string = ''

@description('Environment-specific app settings')
param appSettings array = []

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryUrl}/${dockerImageName}'
      alwaysOn: false
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: managedIdentityId
      appSettings: concat([
        {
          name: 'WEBSITES_PORT'
          value: '80'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryUrl}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Development'
        }
      ], appSettings)
    }
  }
}

@description('The resource ID of the App Service')
output id string = appService.id

@description('The name of the App Service')
output name string = appService.name

@description('The default hostname of the app')
output defaultHostname string = appService.properties.defaultHostName

@description('The URL of the app')
output uri string = 'https://${appService.properties.defaultHostName}'

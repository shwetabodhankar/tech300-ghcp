@description('The name of the Application Insights instance')
param appInsightsName string

@description('Azure region for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('The resource ID of the Log Analytics workspace')
param workspaceId string

@description('Application type')
param kind string = 'web'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: kind
  properties: {
    Application_Type: kind
    WorkspaceResourceId: workspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The resource ID of the Application Insights instance')
output id string = applicationInsights.id

@description('The name of the Application Insights instance')
output name string = applicationInsights.name

@description('The instrumentation key')
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('The connection string')
output connectionString string = applicationInsights.properties.ConnectionString

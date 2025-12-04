@description('The name of the Log Analytics workspace')
param workspaceName string

@description('Azure region for the workspace')
param location string = resourceGroup().location

@description('Tags to apply to the workspace')
param tags object = {}

@description('Workspace data retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Workspace daily quota in GB (-1 for unlimited)')
param dailyQuotaGb int = -1

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The resource ID of the Log Analytics workspace')
output id string = logAnalytics.id

@description('The name of the Log Analytics workspace')
output name string = logAnalytics.name

@description('The workspace ID (customer ID)')
output customerId string = logAnalytics.properties.customerId

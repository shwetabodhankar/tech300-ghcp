targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g., dev, test, prod)')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
@allowed([
  'westus3'
])
param location string = 'westus3'

@description('Name of the project (used for resource naming)')
param projectName string = 'zavastor'

@description('Docker image name and tag')
param dockerImageName string = 'zavastor:latest'

// Generate unique resource names
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  project: projectName
  environment: environmentName
}

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${projectName}-${environmentName}-${location}'
  location: location
  tags: tags
}

// Managed Identity
module managedIdentity 'core/security/managed-identity.bicep' = {
  name: 'managed-identity-deployment'
  scope: rg
  params: {
    identityName: 'id-${projectName}-${environmentName}-${resourceToken}'
    location: location
    tags: tags
  }
}

// Container Registry
module containerRegistry 'core/host/container-registry.bicep' = {
  name: 'container-registry-deployment'
  scope: rg
  params: {
    registryName: 'cr${projectName}${resourceToken}'
    location: location
    tags: tags
    sku: 'Basic'
    adminUserEnabled: false
  }
}

// Log Analytics Workspace
module logAnalytics 'core/monitor/loganalytics.bicep' = {
  name: 'loganalytics-deployment'
  scope: rg
  params: {
    workspaceName: 'log-${projectName}-${environmentName}-${resourceToken}'
    location: location
    tags: tags
    retentionInDays: 30
    dailyQuotaGb: -1
  }
}

// Application Insights
module applicationInsights 'core/monitor/applicationinsights.bicep' = {
  name: 'applicationinsights-deployment'
  scope: rg
  params: {
    appInsightsName: 'appi-${projectName}-${environmentName}-${resourceToken}'
    location: location
    tags: tags
    workspaceId: logAnalytics.outputs.id
    kind: 'web'
  }
}

// Storage Account for AI Hub
module storage 'core/ai/storage.bicep' = {
  name: 'storage-deployment'
  scope: rg
  params: {
    storageAccountName: 'st${projectName}${resourceToken}'
    location: location
    tags: tags
    sku: 'Standard_LRS'
  }
}

// Key Vault for AI Hub
module keyVault 'core/security/keyvault.bicep' = {
  name: 'keyvault-deployment'
  scope: rg
  params: {
    keyVaultName: 'kvzava${resourceToken}'
    location: location
    tags: tags
    enableRbacAuthorization: true
    sku: 'standard'
  }
}

// AI Services
module aiServices 'core/ai/ai-services.bicep' = {
  name: 'aiservices-deployment'
  scope: rg
  params: {
    aiServicesName: 'ais-${projectName}-${environmentName}-${resourceToken}'
    location: location
    tags: tags
    sku: 'S0'
    kind: 'AIServices'
  }
}

// AI Hub (Azure AI Foundry)
module aiHub 'core/ai/ai-hub.bicep' = {
  name: 'aihub-deployment'
  scope: rg
  params: {
    hubName: 'aih${resourceToken}'
    location: location
    tags: tags
    aiServicesId: aiServices.outputs.id
    storageAccountId: storage.outputs.id
    keyVaultId: keyVault.outputs.id
    applicationInsightsId: applicationInsights.outputs.id
    friendlyName: 'ZavaStorefront AI Hub (${environmentName})'
    hubDescription: 'Azure AI Foundry Hub for ZavaStorefront - supports GPT-4 and Phi models'
  }
}

// App Service Plan
module appServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'appserviceplan-deployment'
  scope: rg
  params: {
    planName: 'asp-${projectName}-${environmentName}-${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'B1'
      tier: 'Basic'
      size: 'B1'
      family: 'B'
      capacity: 1
    }
    kind: 'Linux'
  }
}

// App Service
module appService 'core/host/appservice.bicep' = {
  name: 'appservice-deployment'
  scope: rg
  params: {
    appName: 'app-${projectName}-${environmentName}-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'src' })
    appServicePlanId: appServicePlan.outputs.id
    managedIdentityId: managedIdentity.outputs.identityId
    containerRegistryUrl: containerRegistry.outputs.loginServer
    dockerImageName: dockerImageName
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    appSettings: [
      {
        name: 'AZURE_OPENAI_ENDPOINT'
        value: aiServices.outputs.endpoint
      }
      {
        name: 'AI_HUB_WORKSPACE_ID'
        value: aiHub.outputs.workspaceId
      }
    ]
  }
}

// Role Assignment: ACR Pull for App Service
resource acrPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role
}

module acrPullRoleAssignment 'core/security/role-assignment.bicep' = {
  name: 'acrpull-role-assignment'
  scope: rg
  params: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitionId: acrPullRoleDefinition.id
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment: Cognitive Services User for App Service
resource cognitiveServicesUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908' // Cognitive Services User
}

module cognitiveServicesRoleAssignment 'core/security/role-assignment.bicep' = {
  name: 'cognitiveservices-role-assignment'
  scope: rg
  params: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitionId: cognitiveServicesUserRole.id
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment: Key Vault Secrets User for App Service
resource keyVaultSecretsUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
}

module keyVaultRoleAssignment 'core/security/role-assignment.bicep' = {
  name: 'keyvault-role-assignment'
  scope: rg
  params: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitionId: keyVaultSecretsUserRole.id
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_APP_SERVICE_NAME string = appService.outputs.name
output AZURE_APP_SERVICE_URL string = appService.outputs.uri
output APPLICATIONINSIGHTS_CONNECTION_STRING string = applicationInsights.outputs.connectionString
output AZURE_AI_SERVICES_ENDPOINT string = aiServices.outputs.endpoint
output AZURE_AI_HUB_NAME string = aiHub.outputs.name
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_MANAGED_IDENTITY_CLIENT_ID string = managedIdentity.outputs.clientId

using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'dev')
param location = 'westus3'
param projectName = 'zavastor'
param dockerImageName = 'zavastor:latest'

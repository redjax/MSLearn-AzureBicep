@description('The name of the environment. Options: ["dev", "test", "prod"].')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The unique name of the solution.')
@minLength(5)
@maxLength(30)
param solutionName string = 'toyhr-new1${uniqueString(resourceGroup().id)}'

@description('Number of App Service plan instances.')
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

// The appServicePlanSku will be loaded from your params JSON file
@description('The name & tier of the App Service plan SKU.')
param appServicePlanSku object

@description('The Azure region into which the resources should be deployed.')
param location string = 'eastus'

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server')
param sqlServerAdministratorPassword string

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}-${solutionName}-app'
var sqlDatabaseName = 'Employees'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId:appServicePlan.id
    httpsOnly: true
  }
}

// Add SQL server
resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: sqlDatabaseSku.name
    tier: sqlDatabaseSku.tier
  }
}

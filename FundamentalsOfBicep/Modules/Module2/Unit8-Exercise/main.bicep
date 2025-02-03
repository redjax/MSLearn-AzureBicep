param location string = 'eastus'
param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

// var appServicePlanName = 'toy-product-launch-plan' // Imported from modules/appService.bicep
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
// var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1' // Imported from modules/appService.bicep

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Imported from modules/appService.bicep
// resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
//   name: appServicePlanName
//   location: location
//   sku: {
//     name: appServicePlanSkuName
//   }
// }

// Imported from modules/appService.bicep
// resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = {
//   name: appServiceAppName
//   location: location
//   properties: {
//     serverFarmId: appServicePlan.id
//     httpsOnly: true
//   }
// }

// Import the modules/appService.bicep module
module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}

// Output the appService module's output
output appServiceHostName string = appService.outputs.appServiceAppHostName

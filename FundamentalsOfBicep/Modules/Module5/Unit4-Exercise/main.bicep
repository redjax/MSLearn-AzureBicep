@description('The Azure region into which the resources should be deployed.')
param location string = 'westus3'

@description('The name of the App Service app.')
param appServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

@description('Indicates whether a CDN should be deployed.')
param deployCdn bool = true

// Import the app.bicep module
module app 'modules/app.bicep' = {
  name: 'toy-launch-app'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
  }
}

// Import the cdn.bicep module
module cdn 'modules/cdn.bicep' = {
  name: 'toy-launch-cdn'
  params: {
    httpsOnly: true
    originHostName: app.outputs.appServiceAppHostName
  }
}

var appServicePlanName = 'toy-product-launch-plan'

// Output the hostname of the deployed website
// Use CDN's endpoint hostname if CDN is deployed, else use deploy app's appServiceAppHostName
@description('The host name to use to access the website.')
output websiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName

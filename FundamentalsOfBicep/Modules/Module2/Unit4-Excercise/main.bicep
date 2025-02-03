// Define storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
    name: 'epiteststorageaccount1'
    location: 'eastus'
    sku: {
        name: 'Standard_LRS'
    }
    kind: 'StorageV2'
    properties: {
        accessTier: 'Hot'
    }
}

// Define App Service plan
resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
    name: 'toy-product-launch-plan-starter'
    location: 'eastus'
    sku: {
        name: 'F1'
    }
}

// Define App Service application
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
    name: 'epi-testtoylaunch1'
    location: 'eastus'
    properties: {
        serverFarmId: appServicePlan.id
        httpsOnly: true
    }
}

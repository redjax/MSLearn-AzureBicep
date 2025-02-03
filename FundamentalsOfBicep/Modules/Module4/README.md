# Module 4 - Build flexible Bicep templates by using conditions and loops

- [Module](https://learn.microsoft.com/en-us/training/modules/build-flexible-bicep-templates-conditions-loops/)

## Notes

### Conditionals

#### Basic conditions

You can use the `if` keyword followed by a condition during resource deployment. The condition should resolve to a boolean `true`/`false`.

For example, deploying a resource only if a param `deployStorageAccount` is found:

```bicep
param deployStorageAccount bool

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = if (deployStorageAccount) {
    name: 'teddybearstorage'
    location: resourceGroup().location
    kind: 'StorageV2'
    // ...
}
```

#### Use expressions as conditions

You can use expressions in a conditional to create an evaluation:

```bicep
// Declare a parameter user can set to define resource's environment
@allowed([
    'Development'
    'Production'
])
param environmentName string

// Use the input environmentName to only deploy resources with a 'Production' environmentName
resource auditSettings 'Microsoft.Sql/servers/auditingSettings@2023-08-01-preview' = if (environmentName == 'Production') {
    parent: server
    name: 'default'
    properties: {
        // ...
    }
}
```

It is good practice to create a variable for the expression's evaluation output:

```bicep
@allowed([
    'Development'
    'Production'
])
param environmentName string

// Enable auditing when in 'Production' environment
var auditingEnabled = environmentName == 'Production'

resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2023-08-01-preview' = if (auditingEnabled) {
    // run only if auditingEnabled evaluated to true
    parent: server
    name: 'default'
    properties: {
        // ...
    }
}
```

#### Depend on conditionally deployed resources

Sometimes you want to deploy a resource only if another resource has finished deploying, or was deployed in a specific state. You can use dependencies in evaluations to accomplish this:

```bicep
@allowed([
    'Development'
    'Production'
])
param environmentName string
param location string = resourceGroup().location
param auditStorageAccountName string = 'bearaudit${uniqueString(resourceGroup().id)}'

var auditingEnabled = environmentName = 'Production'
var storageAccountSkuName = 'Standard_LRS'

// Deploy resource only if auditing is enabled (i.e. for Production resources)
resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' if (auditingEnabled) {
    name: auditStorageAccountName
    location: location
    sku: {
        name: storageAccountSkuName
    }
    kind: 'StorageV2'
}

// Only apply auditing settings to auditingEnabled resources (i.e. for Production resources)
resource auditingSettings 'Microsoft.Sql/servers/auditSettings@2023-08-01-preview' = if (auditingEnabled) {
    parent: server
    name: 'default'
    properties: {
        state: 'Enabled'
        // Tell auditingSettings to use the storage account if environmentName='Production', disable if environmentName='Development'
        storageEndpoint: environmentName == 'Production' ? auditStorageAccount.properties.primaryEndpoints.blob : ''
        // Give auditingSettings an access key if environmentName='Production'
        storageAccountAccessKey: environmentName == 'Production' ? listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value : ''
    }
}
```

The `?` operator evaluates a condition before (`environmentName == 'Production'`), uses the value immediately after if `true` (`listkeys(...)`), and uses the value after `:` as a default if the condition does not match (`... : ''`).

### Loops

Loops help you to avoid having to repeat resource definitions. When you need to deploy multiple similar resources, you can loop through them to customize the properties of each instance & deploy them.

#### Copy loops

You can use the `for` keyword when defining a resource or module to specify how Bicep should create additional resources:

```bicep
// Create an array of account names Bicep will loop through when creating a resource
param storageAccountNames array = [
    'saauditus'
    'saauditeurope'
    'saauditapac'
]

resource storageAccountResources 'Microsoft.Storage/storageAccount@2023-05-01' = [for storageAccountName in storageAccountNames: {
    // Use a value from the loop for the storage account name
    name: storageAccountName
    location: resourceGroup().location
    kind: 'StorageV2'
    sku: {
        name: 'Standard_LRS'
    }
}]
```

#### Count-based loops

To limit the number of times a loop executes, you can use `range()` to define a starting & stopping point:

```bicep
// Execute 'for' loop 4 times
resource storageAccountResources 'Microsoft.Storage/storageAccount@2023-05-01' = [for i in range (1,4): {
    // Use loop count 'i' incrementor for name
    name: 'sa${i}'
    location: resourceGroup().location
    kind: 'StorageV2'
    sku: {
            name: 'Standard_LRS'
    }
}]
```

You can use the `i` iterator to access items in an array by index. Note that loops start at index `0`, while array indexes start at `1`, so you need to add 1 to the iterator (`${i+1}`):

```bicep
// Array of locations to loop over
param locations array = [
    'westeurope'
    'eastus2'
    'eastasia'
]

// Create resources, looping over location names to create unique resource names
resource sqlServers 'Microsoft.Sql/servers@2023-08-01-preview' = [for (location, i) in locations: {
    // Name resource based on loop count & corresponding array item by index matching count
    //   i.e. count=0 = locations[1]  (count 0 + 1)
    name: 'sqlserver-${i+1}'
    properties: {
        administratorLogin: administratorLogin
        administratorLoginPassword: administratorLoginPassword
    }
}]
```

#### Filter items with loops

You can control loop iterations using `if` statements in `for` loops, for example to limit resource deployment to a specific environment like `Production`:

```bicep
// Define 3 resources with environmentName params
param sqlServerDetails array = [
    {
        name: 'sqlserver-we'
        location: 'westeurope'
        environmentName: 'Production'
    }
    {
        name: 'sqlserver-eus2'
        location: 'eastus2'
        environmentName: 'Development'
    }
    {
        name: 'sqlserver-eas'
        location: 'eastasia'
        environmentName: 'Production'
    }
]

// Define resources only if environmentName='Production'
resource sqlServers 'Microsoft.Sql/servers@2023-08-01-preview' = [for sqlServer in sqlServerDetails: if (sqlServer.environmentName == 'Production') {
    name: sqlServer.name
    location: sqlServer.location
    properties: {
        administratorLogin: administratorLogin
        administratorLoginPassword: administratorLoginPassword
    }
    tags: {
        environment: sqlServer.environmentName
    }
}]
```

#### Control loops & nested loops

By default, Azure Resource Manager evaluates loops in parallel & in a non-deterministic order. Sometimes, you need to deploy resources sequentially, like when one resource depends on the existence of another. You might also want to only apply some changes to specific resources on subsequent executions.

You can control Bicep loops with the `@batchSize()` decorator.

For example, this template deploys all resources at the same time, in parallel:

```bicep
resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = [for i in range(1, 3): {
    name: 'app${i}'
}]
```

Add the `@batchSize(2)` decorator to tell Azure Resource Manager to only deploy 2 resources at a time:

```bicep
@batchSize(2)
resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = [for i in range(1, 3): {
    name: 'app${i}'
}]
```

Bicep waits for each batch to finish before moving to the next. If a service in the first batch finishes before another, Bicep will wait to finish the whole deployment batch before moving onto the next batch.

#### Using loops with resource properties

You can also use loops to help set resource properties. For example, when deploying a virtual network, you can use a loop to parametrize a subnet, like `addressPrefix: '10.0.${i}.0/24'`:

```bicep
param subnetNames array = [
    'api'
    'worker'
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
    name: 'teddybear'
    location: resourceGroup().location
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.0.0.0/16'
            ]
        }
        subnets: [for (subnetName, i) in subnetNames: {
            name: subnetName
            properties: {
                addressPrefix: '10.0.${i}.0/24'
            }
        }]
    }
}
```

#### Nested loops

You can create nested loops in Bicep for "stacked" conditionals. For example, deploying a virtual network in every country/region you've specified in a `locations` array (this example creates a new subnet, `10.x.0.0`, for each pass of the loop, i.e. `10.1.0.0`, `10.2.0.0`, ...):

```bicep
param locations array = [
    'westeurope'
    'eastus2'
    'eastasia'
]

var subnetCount = 2

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2024-01-01' = [for (location, i) in locations: {
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.${i}.0.0/16'
            ]
        }
    }
}]
```

A more detailed example using a nested loop to create subnets & template virtual network resource names:

```bicep
resource virtualNetworks 'Microsoft.Network/virtualNetworks@2024-01-01' = [for (location, i) in locations: {
    name: 'vnet-${location}'
    properties: {
        addressSpace: {
            addressPrefixes: [
                '10.${i}.0.0/16'
            ]
        }
        subnets: [for j in range(1, subnetCount): {
            name: 'subnet-${j}'
            properties: {
                addressPrefix: '10.${i}.${j}.0/24'
            }
        }]
    }
}]
```

Deploying this template would create the following virtual networks and subnets:

| Virtual network name | Location | Address | prefix | Subnets |
| -------------------- | -------- | ------- | ------ | ------- |
| vnet-westeurope | westeurope | 10.0.0.0/16 | 10.0.1.0/24, 10.0.2.0/24 |
| vnet-eastus2 | eastus2 | 10.1.0.0/16 | 10.1.1.0/24, 10.1.2.0/24 |
| vnet-eastasia | eastasia | 10.2.0.0/16 | 10.2.1.0/24, 10.2.2.0/24 |

#### Variables &output loops

For templates you will re-use repeatedly that may have slight variations on each deployment, you can use variables to make the templates more flexible. You can also assign evaluation outputs to a variable, like:

```bicep
var items = [for i in range(1, 5): 'item${i}']
// items = [item1, item2, item3, item4, item5]
```

Here is an example that sets a subnet range based on a loop of an array of objects:

```bicep
param addressPrefix string = '10.10.0.0/16'
param subnets array = [
    {
        name: 'frontend'
        ipAddressRange: '10.10.0.0/24'
    }
    {
        name: 'backend'
        ipAddressRange: '10.10.1.0/24'
    }
]

var subnetsProperty = [for subnet in subnets: {
    name: subnet.name
    properties: {
        addressPrefix: subnet.ipAddressRange
    }
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
    name: 'teddybear'
    location: resourceGroup().location
    properties: {
        addressSpace: {
            addressPrefixes: [
                addressPrefix
            ]
        }
        subnets: subnetsProperty
    }
}
```

#### Output loops

You can use Bicep outputs to provide information from your deployments back to the user or tool that started the deployment. Output loops give you the flexibility and power of loops within your outputs.

```bicep
var items = [
    'item1'
    'item2'
    'item3'
    'item4'
    'item5'
]

output outputItems array = [for i in range(0, length(items)): items[i]]
```

Output loops are normally used in conjunction with other loops in a template. For example, this template deploys a set of storage accounts to Azure regions specified by a `locations` parameter:

```bicep
param locations array = [
    'westeurope'
    'eastus2'
    'eastasia'
]

resource storageAccounts 'Microsoft.Storage/storageAccounts@2023-05-01' = [for location in locations: {
    name: 'toy${uniqueString(resourceGroup().id, location)}'
    location: location
    kind: 'StorageV2'
    sku: {
        name: 'Standard_LRS'
    }
}]

// Create an output loop to output the name & endpoint for each resource
output storageEndpoints array = [for i in range(0, length(locations)): {
    name: storageAccounts[i].name
    location: storageAccounts[i].location
    blobEndpoint: storageAccounts[i].properties.primaryEndpoints.blob
    fileEndpoint: storageAccounts[i].properties.primaryEndpoints.file
}]
```

**WARNING**: *NEVER* use outputs to return a secret, such as an access key or a password. Outputs are logged, and are not designed for handling secure data.

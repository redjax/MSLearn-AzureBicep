@description('The Azure regions into which the resources should be deployed.')
param locations array = [
  'canadacentral'
  'eastus2'
  'eastasia'
]

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorLoginPassword string

// Import the database.bicep module, passing params from this template into the databases module.
// Loop over locations in the 'locations' array, use substitution for resource names based on location.
module databases 'modules/database.bicep' = [for location in locations: {
  name: 'database-${location}'
  params: {
    location: location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}]

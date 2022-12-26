param sqlAdminUser string

@secure()
param sqlAdminPassword string

param name string
param databaseName string
param serverEdition string
param dbInstanceType string
param version string
param keyVaultName string

param location string = resourceGroup().location
param tags object = {}

param connectionStringKey string = 'AZURE-PSQL-CONNECTION-STRING'

resource psqlServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: name
  location: location
  tags: union(tags, { 'spring-cloud-azure': true })
  sku: {
    name: dbInstanceType
    tier: serverEdition
  }
  properties: {
    version: version
    createMode: 'Default'
    administratorLogin: sqlAdminUser
    administratorLoginPassword: sqlAdminPassword
  }

  resource database 'databases' = {
    name: 'todo'
  }

  resource firewall 'firewallRules' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }

  // resource psql_azure_extensions 'configurations' = {
  //   name: 'azure.extensions'
  //   properties: {
  //     value: 'UUID-OSSP'
  //     source: 'user-override'
  //   }
  // }

}


resource sqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'sqlAdminPassword'
  properties: {
    value: sqlAdminPassword
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

output connectionStringKey string = connectionStringKey
output name string = psqlServer.name
output databasName string = databaseName

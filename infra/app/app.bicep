param name string
param location string = resourceGroup().location
param tags object = {}

param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = ''
param psqlName string
param psqlDataBaseName string
param psqlUserName string
@secure()
param psqlUserPassword string
param serviceName string = 'app'


module app '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    env: [
      {
        name: 'AZURE_POSTGRESQL_URL'
        value: 'jdbc:postgresql://${psql.properties.fullyQualifiedDomainName}:5432/${psqlDataBaseName}?sslmode=require'
      }
      {
        name: 'AZURE_POSTGRESQL_USERNAME'
        value: '${psqlUserName}@${psql.name}'
      }
      {
        name: 'AZURE_POSTGRESQL_PASSWORD'
        value: psqlUserPassword
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
    ]
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    targetPort: 3100
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource psql 'Microsoft.DBforPostgreSQL/servers@2017-12-01' existing = {
  name: psqlName
}

output SERVICE_API_IDENTITY_PRINCIPAL_ID string = app.outputs.identityPrincipalId
output SERVICE_API_NAME string = app.outputs.name
output SERVICE_API_URI string = app.outputs.uri
output SERVICE_API_IMAGE_NAME string = app.outputs.imageName

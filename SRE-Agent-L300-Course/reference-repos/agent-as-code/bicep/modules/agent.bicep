// --------------------------------------------------------------------------
// Module: SRE Agent Resource
// --------------------------------------------------------------------------

@description('Name of the SRE Agent resource.')
param agentName string

@description('Azure region.')
param location string

@description('Tags applied to all resources.')
param tags object

@description('Model provider: Anthropic or AzureOpenAI.')
@allowed([
  'Anthropic'
  'AzureOpenAI'
])
param modelProvider string

@description('Resource ID of the User-Assigned Managed Identity.')
param uamiId string

@description('App Insights connection string for telemetry.')
param appInsightsConnectionString string

@description('Log Analytics workspace resource ID.')
param logAnalyticsWorkspaceId string

resource sreAgent 'Microsoft.AzureSREAgent/agents@2024-01-01-preview' = {
  name: agentName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiId}': {}
    }
  }
  properties: {
    modelProvider: modelProvider
    appInsightsConnectionString: appInsightsConnectionString
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

output agentId string = sreAgent.id
output agentName string = sreAgent.name

// --------------------------------------------------------------------------
// Azure SRE Agent — Infrastructure as Code (Bicep)
// Deploys: SRE Agent, UAMI, App Insights, Log Analytics, Role Assignments
// Uses modular architecture — see modules/ for individual resource definitions.
// Reference: https://sre.azure.com/docs
// --------------------------------------------------------------------------

@description('Name of the SRE Agent resource.')
param agentName string

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Model provider: Anthropic (default) or AzureOpenAI (EUDB).')
@allowed([
  'Anthropic'
  'AzureOpenAI'
])
param modelProvider string = 'Anthropic'

@description('Environment tag for cost tracking.')
param environment string = 'workshop'

@description('Tags applied to all resources.')
param tags object = {
  workshop: 'srea-l300'
  environment: environment
}

// --------------------------------------------------------------------------
// Modules
// --------------------------------------------------------------------------

module monitoring 'modules/monitoring.bicep' = {
  name: '${agentName}-monitoring'
  params: {
    agentName: agentName
    location: location
    tags: tags
  }
}

module uami 'modules/uami.bicep' = {
  name: '${agentName}-uami'
  params: {
    agentName: agentName
    location: location
    tags: tags
  }
}

module agent 'modules/agent.bicep' = {
  name: '${agentName}-agent'
  params: {
    agentName: agentName
    location: location
    tags: tags
    modelProvider: modelProvider
    uamiId: uami.outputs.uamiId
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}

// --------------------------------------------------------------------------
// Role Assignments — per M1 promotion-playbook matrix
// --------------------------------------------------------------------------

// Reader on the resource group (baseline for all agents)
resource readerRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uami.outputs.uamiId, 'Reader')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') // Reader
    principalId: uami.outputs.uamiPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Monitoring Contributor (required for Azure Monitor alert ack/close)
resource monitoringContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uami.outputs.uamiId, 'MonitoringContributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '749f88d5-cbae-40b8-bcfc-e573ddc772fa') // Monitoring Contributor
    principalId: uami.outputs.uamiPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Log Analytics Reader (for querying logs)
resource logAnalyticsReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uami.outputs.uamiId, 'LogAnalyticsReader')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '73c42c96-874c-492b-b04d-ab87d138a893') // Log Analytics Reader
    principalId: uami.outputs.uamiPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// --------------------------------------------------------------------------
// Outputs
// --------------------------------------------------------------------------
output agentEndpoint string = agent.outputs.agentId
output appInsightsConnectionString string = monitoring.outputs.appInsightsConnectionString
output logAnalyticsWorkspaceId string = monitoring.outputs.logAnalyticsWorkspaceId
output uamiClientId string = uami.outputs.uamiClientId
output uamiPrincipalId string = uami.outputs.uamiPrincipalId

// --------------------------------------------------------------------------
// Module: App Insights + Log Analytics Workspace
// --------------------------------------------------------------------------

@description('Name of the SRE Agent (used as prefix for monitoring resources).')
param agentName string

@description('Azure region.')
param location string

@description('Tags applied to all resources.')
param tags object

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${agentName}-law'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

// Application Insights (workspace-based)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${agentName}-ai'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsId string = appInsights.id
output logAnalyticsWorkspaceId string = logAnalytics.id

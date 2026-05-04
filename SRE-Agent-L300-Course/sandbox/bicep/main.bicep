// =============================================================================
// SRE Agent L300/400 Workshop — Subscription-scope master Bicep template (D1)
// Deploys per-attendee sandbox: RG, UAMI, App Insights, Log Analytics, ADX, sample workload
// =============================================================================
targetScope = 'subscription'

@description('Attendee GitHub handle or alias')
param attendeeHandle string

@description('Incident platform track: pagerduty | servicenow | azure-monitor')
@allowed(['pagerduty', 'servicenow', 'azure-monitor'])
param incidentPlatform string

@description('Deployment region')
@allowed(['swedencentral', 'eastus2', 'australiaeast'])
param location string = 'eastus2'

@description('UTC expiration timestamp for auto-cleanup')
param expiresUtc string = dateTimeAdd(utcNow(), 'P1D')

@description('Daily cost cap in USD')
param costCapUsd int = 50

// -----------------------------------------------------------------------------
// Computed names
// -----------------------------------------------------------------------------
var rgName = 'rg-srea-l300-${attendeeHandle}'
var tags = {
  workshop: 'srea-l300'
  attendee: attendeeHandle
  expires: expiresUtc
  'incident-platform': incidentPlatform
}

// -----------------------------------------------------------------------------
// Per-attendee Resource Group
// -----------------------------------------------------------------------------
resource attendeeRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgName
  location: location
  tags: tags
}

// -----------------------------------------------------------------------------
// Deploy per-attendee infrastructure into the RG
// -----------------------------------------------------------------------------
module attendeeInfra 'modules/attendee-rg.bicep' = {
  name: 'deploy-${attendeeHandle}'
  scope: attendeeRg
  params: {
    attendeeHandle: attendeeHandle
    incidentPlatform: incidentPlatform
    location: location
    tags: tags
    costCapUsd: costCapUsd
    expiresUtc: expiresUtc
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
output resourceGroupName string = attendeeRg.name
output agentEndpointUrl string = attendeeInfra.outputs.agentEndpointUrl
output appInsightsConnectionString string = attendeeInfra.outputs.appInsightsConnectionString
output adxClusterUrl string = attendeeInfra.outputs.adxClusterUrl
output sampleWorkloadUrl string = attendeeInfra.outputs.sampleWorkloadUrl
output uamiClientId string = attendeeInfra.outputs.uamiClientId
output uamiPrincipalId string = attendeeInfra.outputs.uamiPrincipalId

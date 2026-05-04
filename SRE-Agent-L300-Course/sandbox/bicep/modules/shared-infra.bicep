// =============================================================================
// Shared infrastructure module (optional)
// Deploys resources shared across all attendees in a single workshop cohort:
//   - Shared Log Analytics workspace for cost aggregation
//   - Shared ADX cluster (if per-attendee free-tier is unavailable in region)
// =============================================================================
targetScope = 'resourceGroup'

@description('Azure region')
param location string

@description('Workshop cohort identifier (e.g., 2026-05-cohort1)')
param cohortId string

var tags = {
  workshop: 'srea-l300'
  cohort: cohortId
  role: 'shared-infra'
}

// -----------------------------------------------------------------------------
// Shared Log Analytics (cost roll-up view across all attendee workspaces)
// -----------------------------------------------------------------------------
resource sharedLaw 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-srea-shared-${cohortId}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// -----------------------------------------------------------------------------
// Shared ADX cluster (use only if per-attendee free-tier is region-constrained)
// SKU: Dev(No SLA) free tier
// -----------------------------------------------------------------------------
resource sharedAdx 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: 'adxsreashared${take(uniqueString(resourceGroup().id, cohortId), 8)}'
  location: location
  tags: tags
  sku: {
    name: 'Dev(No SLA)_Standard_E2a_v4'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    enableStreamingIngest: false
    enablePurge: false
  }
}

// Per-attendee databases can be created on this cluster via the ADX seed scripts

output sharedLawId string = sharedLaw.id
output sharedLawCustomerId string = sharedLaw.properties.customerId
output sharedAdxClusterUri string = sharedAdx.properties.uri
output sharedAdxClusterName string = sharedAdx.name

// ──────────────────────────────────────────────────────────────
// shared.bicep — Workshop-level shared resources
// Deploys into an existing resource group (resource-group scope).
// ──────────────────────────────────────────────────────────────

param location string
param workshopPrefix string

resource sharedLaw 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${workshopPrefix}-shared'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

output sharedLawId string = sharedLaw.id
output sharedLawName string = sharedLaw.name

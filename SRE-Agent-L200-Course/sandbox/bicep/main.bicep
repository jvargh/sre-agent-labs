// ──────────────────────────────────────────────────────────────
// main.bicep — SRE Agent L200 Workshop Sandbox
// Subscription-scope deployment. Creates per-attendee resource
// groups with isolated workloads, plus shared workshop resources.
// ──────────────────────────────────────────────────────────────
targetScope = 'subscription'

// ─── Parameters ──────────────────────────────────────────────
@description('List of attendee aliases (e.g., ["alice", "bob", "charlie"])')
param attendeeAliases array

@description('Azure region for all resources')
@allowed([
  'swedencentral'
  'eastus2'
  'australiaeast'
])
param location string = 'swedencentral'

@description('Name of the shared resource group for workshop-level resources')
param sharedResourceGroupName string = 'rg-sre-workshop-shared'

@description('Prefix used for shared resource naming')
param workshopPrefix string = 'sre-workshop'

// ─── Shared Resource Group ───────────────────────────────────
resource sharedRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: sharedResourceGroupName
  location: location
}

// ─── Shared Resources ────────────────────────────────────────
module sharedInfra 'modules/shared.bicep' = {
  name: 'deploy-shared-infra'
  scope: sharedRg
  params: {
    location: location
    workshopPrefix: workshopPrefix
  }
}

// ─── Per-Attendee Resource Groups ────────────────────────────
resource attendeeRgs 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for alias in attendeeAliases: {
    name: 'rg-sre-agent-${alias}'
    location: location
  }
]

// ─── Per-Attendee Resources ──────────────────────────────────
module attendeeEnvs 'modules/attendee.bicep' = [
  for (alias, i) in attendeeAliases: {
    name: 'deploy-attendee-${alias}'
    scope: attendeeRgs[i]
    params: {
      location: location
      alias: alias
    }
  }
]

// ─── Subscription-Scoped RBAC: Monitoring Contributor ────────
// Monitoring Contributor role ID
var monitoringContributorRoleId = '749f88d5-cbae-40b8-bcfc-e573ddc772fa'

// Role assignment name must be deterministic at deploy start — use alias string, not module output.
resource monitoringContributorAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (alias, i) in attendeeAliases: {
    name: guid(subscription().id, 'uami-sre-${alias}', monitoringContributorRoleId)
    properties: {
      principalId: attendeeEnvs[i].outputs.uamiPrincipalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringContributorRoleId)
      principalType: 'ServicePrincipal'
    }
  }
]

// ─── Outputs ─────────────────────────────────────────────────
output sharedLawId string = sharedInfra.outputs.sharedLawId

output attendeeSummary array = [
  for (alias, i) in attendeeAliases: {
    alias: alias
    resourceGroup: 'rg-sre-agent-${alias}'
    containerAppUrl: 'https://${attendeeEnvs[i].outputs.containerAppFqdn}'
    appInsightsConnectionString: attendeeEnvs[i].outputs.appInsightsConnectionString
    lawWorkspaceId: attendeeEnvs[i].outputs.lawWorkspaceId
  }
]

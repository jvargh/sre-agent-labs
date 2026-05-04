// =============================================================================
// Per-attendee resource group module
// Deploys: UAMI + role assignments, Log Analytics, App Insights, ADX free-tier,
//          Container App (sample workload), Key Vault
// =============================================================================

@description('Attendee handle')
param attendeeHandle string

@description('Incident platform track')
param incidentPlatform string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

@description('Daily cost cap USD')
param costCapUsd int

@description('Expiration UTC')
param expiresUtc string

// -----------------------------------------------------------------------------
// Naming
// -----------------------------------------------------------------------------
var baseName = 'sreal300${uniqueString(resourceGroup().id, attendeeHandle)}'
var uamiName = 'uami-srea-${attendeeHandle}'
var lawName = 'law-srea-${attendeeHandle}'
var aiName = 'ai-srea-${attendeeHandle}'
var adxName = 'adx${take(replace(attendeeHandle, '-', ''), 12)}l300'
var kvName = 'kv-srea-${take(baseName, 10)}'
var acaEnvName = 'acaenv-srea-${attendeeHandle}'
var acaName = 'aca-sample-${attendeeHandle}'

// -----------------------------------------------------------------------------
// Built-in role definition IDs (Azure well-known)
// Per MD §M1 decision matrix:
//   - Reader (read-only chat, scheduled tasks notifications-only, low-sev response plans)
//   - Privileged scoped (scheduled tasks Azure write, P1/P2 response plans)
//   - Monitoring Contributor (Azure Monitor ack/close alerts)
// -----------------------------------------------------------------------------
var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var monitoringContributorRoleId = '749f88d5-cbae-40b8-bcfc-e573ddc772fa'

// -----------------------------------------------------------------------------
// User-Assigned Managed Identity
// -----------------------------------------------------------------------------
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: uamiName
  location: location
  tags: tags
}

// Role: Reader on RG (read-only chat, scheduled task reads, low-sev response plans)
resource readerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uami.id, readerRoleId)
  properties: {
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleId)
  }
}

// Role: Contributor scoped to RG (Privileged — for Azure write tasks & P1/P2 response plans)
resource contributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uami.id, contributorRoleId)
  properties: {
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
  }
}

// Role: Monitoring Contributor (Azure Monitor ack/close per M2 Track C)
resource monitoringAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uami.id, monitoringContributorRoleId)
  properties: {
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringContributorRoleId)
  }
}

// -----------------------------------------------------------------------------
// Log Analytics Workspace
// -----------------------------------------------------------------------------
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
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
// Application Insights
// -----------------------------------------------------------------------------
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: aiName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: law.id
    IngestionMode: 'LogAnalytics'
  }
}

// -----------------------------------------------------------------------------
// Azure Data Explorer — Free tier (D9)
// -----------------------------------------------------------------------------
resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxName
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

resource adxDb 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  parent: adxCluster
  name: 'SREWorkshopDB'
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P30D'
    hotCachePeriod: 'P7D'
  }
}

// -----------------------------------------------------------------------------
// Key Vault — credential store for incident platform tokens
// -----------------------------------------------------------------------------
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

// Grant UAMI Key Vault Secrets User on the vault
var kvSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
resource kvSecretAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, uami.id, kvSecretsUserRoleId)
  scope: keyVault
  properties: {
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', kvSecretsUserRoleId)
  }
}

// -----------------------------------------------------------------------------
// Container Apps Environment + Sample Workload
// -----------------------------------------------------------------------------
resource acaEnv 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: acaEnvName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: law.properties.customerId
        sharedKey: law.listKeys().primarySharedKey
      }
    }
  }
}

resource sampleApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: acaName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: acaEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
    }
    template: {
      containers: [
        {
          name: 'sample-workload'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
output uamiClientId string = uami.properties.clientId
output uamiPrincipalId string = uami.properties.principalId
output agentEndpointUrl string = 'https://sre.azure.com'
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output adxClusterUrl string = adxCluster.properties.uri
output sampleWorkloadUrl string = 'https://${sampleApp.properties.configuration.ingress.fqdn}'
output keyVaultUri string = keyVault.properties.vaultUri
output logAnalyticsWorkspaceId string = law.properties.customerId

// --------------------------------------------------------------------------
// Module: User-Assigned Managed Identity
// --------------------------------------------------------------------------

@description('Name of the SRE Agent (used as prefix for UAMI).')
param agentName string

@description('Azure region.')
param location string

@description('Tags applied to all resources.')
param tags object

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${agentName}-uami'
  location: location
  tags: tags
}

output uamiId string = uami.id
output uamiClientId string = uami.properties.clientId
output uamiPrincipalId string = uami.properties.principalId

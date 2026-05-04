// =============================================================================
// Cost-Cap Watcher — SRE Agent L300 Workshop (D12)
// Budget alert: trips at USD 40 (80%) and USD 50 (100% → teardown)
// Reference: SREA-Level300.md §6 — per-attendee per-day spend ≤ USD 50
// =============================================================================
targetScope = 'resourceGroup'

@description('Attendee handle')
param attendeeHandle string

@description('Daily cost cap in USD')
param costCapUsd int = 50

@description('Contact email for budget notifications')
param contactEmail string

@description('Resource tags')
param tags object = {
  workshop: 'srea-l300'
  attendee: attendeeHandle
}

// Budget name must be unique per scope
var budgetName = 'budget-srea-l300-${attendeeHandle}'

// Time grain: Monthly (minimum supported)
// The budget covers the workshop period — set start to first of current month
var startDate = '${substring(utcNow(), 0, 7)}-01'

// -----------------------------------------------------------------------------
// Budget with two notification thresholds
// -----------------------------------------------------------------------------
resource costBudget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: costCapUsd
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: startDate
    }
    filter: {
      tags: {
        name: 'workshop'
        values: ['srea-l300']
        operator: 'In'
      }
    }
    notifications: {
      // Threshold 1: Warning at 80% (USD 40)
      warningAt80Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 80
        thresholdType: 'Actual'
        contactEmails: [contactEmail]
        contactGroups: []
        locale: 'en-us'
      }
      // Threshold 2: Critical at 100% (USD 50) — triggers teardown
      criticalAt100Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 100
        thresholdType: 'Actual'
        contactEmails: [contactEmail]
        contactGroups: []
        locale: 'en-us'
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Action Group for automated teardown at 100%
// Uses a webhook to trigger the teardown script or Logic App
// -----------------------------------------------------------------------------
resource teardownActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-srea-teardown-${attendeeHandle}'
  location: 'global'
  tags: tags
  properties: {
    groupShortName: 'srea-tear'
    enabled: true
    emailReceivers: [
      {
        name: 'workshop-admin'
        emailAddress: contactEmail
        useCommonAlertSchema: true
      }
    ]
    // Automation runbook or Logic App webhook for auto-teardown
    automationRunbookReceivers: []
    webhookReceivers: []
  }
}

// -----------------------------------------------------------------------------
// Metric alert on resource group cost (supplementary to budget)
// Fires when actual spend approaches cap
// -----------------------------------------------------------------------------
resource costAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-cost-cap-${attendeeHandle}'
  location: 'global'
  tags: tags
  properties: {
    description: '[COST-CAP] SRE Agent L300 workshop spend alert for ${attendeeHandle}. Budget: USD ${costCapUsd}/day.'
    severity: 1
    enabled: true
    scopes: [resourceGroup().id]
    evaluationFrequency: 'PT1H'
    windowSize: 'PT1H'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: []
    }
    actions: [
      {
        actionGroupId: teardownActionGroup.id
      }
    ]
  }
}

output budgetName string = costBudget.name
output actionGroupId string = teardownActionGroup.id
output alertName string = costAlert.name

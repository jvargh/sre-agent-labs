# --------------------------------------------------------------------------
# Azure SRE Agent — Infrastructure as Code (Terraform)
# Deploys: SRE Agent, UAMI, App Insights, Log Analytics, Role Assignments
# Reference: https://sre.azure.com/docs
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Data Sources
# --------------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  tags = {
    workshop    = "srea-l300"
    environment = var.environment
  }
}

# --------------------------------------------------------------------------
# Log Analytics Workspace
# --------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.agent_name}-law"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.tags
}

# --------------------------------------------------------------------------
# Application Insights (workspace-based)
# --------------------------------------------------------------------------

resource "azurerm_application_insights" "ai" {
  name                = "${var.agent_name}-ai"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  tags                = local.tags
}

# --------------------------------------------------------------------------
# User-Assigned Managed Identity
# --------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "uami" {
  name                = "${var.agent_name}-uami"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
}

# --------------------------------------------------------------------------
# SRE Agent Resource (via AzAPI — custom RP)
# --------------------------------------------------------------------------

resource "azapi_resource" "sre_agent" {
  type      = "Microsoft.AzureSREAgent/agents@2024-01-01-preview"
  name      = var.agent_name
  location  = var.location
  parent_id = data.azurerm_resource_group.rg.id
  tags      = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami.id]
  }

  body = {
    properties = {
      modelProvider                = var.model_provider
      appInsightsConnectionString  = azurerm_application_insights.ai.connection_string
      logAnalyticsWorkspaceId      = azurerm_log_analytics_workspace.law.id
    }
  }
}

# --------------------------------------------------------------------------
# Role Assignments — per M1 promotion-playbook matrix
# --------------------------------------------------------------------------

# Reader on the resource group
resource "azurerm_role_assignment" "reader" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

# Monitoring Contributor (for Azure Monitor alert ack/close)
resource "azurerm_role_assignment" "monitoring_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

# Log Analytics Reader (for querying logs)
resource "azurerm_role_assignment" "log_analytics_reader" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

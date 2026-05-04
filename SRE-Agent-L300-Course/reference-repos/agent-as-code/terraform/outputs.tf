# --------------------------------------------------------------------------
# Outputs — Azure SRE Agent IaC
# --------------------------------------------------------------------------

output "agent_id" {
  description = "Resource ID of the deployed SRE Agent."
  value       = azapi_resource.sre_agent.id
}

output "app_insights_connection_string" {
  description = "App Insights connection string for agent telemetry."
  value       = azurerm_application_insights.ai.connection_string
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = azurerm_log_analytics_workspace.law.id
}

output "uami_client_id" {
  description = "Client ID of the User-Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.uami.client_id
}

output "uami_principal_id" {
  description = "Principal ID of the User-Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.uami.principal_id
}

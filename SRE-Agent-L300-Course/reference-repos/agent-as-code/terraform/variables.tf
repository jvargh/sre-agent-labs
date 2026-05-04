# --------------------------------------------------------------------------
# Variables — Azure SRE Agent IaC
# --------------------------------------------------------------------------

variable "agent_name" {
  type        = string
  description = "Name of the SRE Agent resource."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for all resources."
}

variable "model_provider" {
  type        = string
  default     = "Anthropic"
  description = "Model provider: Anthropic (default) or AzureOpenAI (EUDB)."
  validation {
    condition     = contains(["Anthropic", "AzureOpenAI"], var.model_provider)
    error_message = "model_provider must be 'Anthropic' or 'AzureOpenAI'."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "environment" {
  type        = string
  default     = "workshop"
  description = "Environment tag for cost tracking."
}

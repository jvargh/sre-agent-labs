# --------------------------------------------------------------------------
# Provider Configuration — Azure SRE Agent IaC
# --------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.10.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}

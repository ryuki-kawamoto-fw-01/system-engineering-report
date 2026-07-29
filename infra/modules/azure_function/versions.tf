# =============================================================================
# Azure Function Module - Version Constraints
# =============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.56.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "2.0.1"
    }
  }
}

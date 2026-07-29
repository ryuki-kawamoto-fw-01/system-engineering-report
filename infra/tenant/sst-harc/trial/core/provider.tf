terraform {
  required_version = "= 1.14.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.56.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "= 2.0.1"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }

  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-hsuibu"
    storage_account_name = "tfstatehsuibu001"
    container_name       = "tfstate"

    # sst-harc環境専用のStateとして分離する
    key = "sst-harc/core/terraform.tfstate"
  }
}
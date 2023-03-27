terraform {
  backend "azurerm" {
    resource_group_name  = "rg-udf-tfstate-eus2-01"
    storage_account_name = "strtfstateeus2bs001"
    container_name       = "tfstate-container"
    key                  = "dmz.tfstate"
  }

  required_providers {
    azurerm = {
      version = ">=2.91.0"
    }
  }
}

########Configure the Azure Provider
provider "azurerm" {
  features {}
}
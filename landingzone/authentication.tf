terraform {
  backend "azurerm" {
    resource_group_name  = "VSCodeVM-RG"
    storage_account_name = "tfstatestreus2001"
    container_name       = "tfstate-container"
    key                  = "dlz.tfstate"
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
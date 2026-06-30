terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfdevafrah001"
    container_name       = "tfstate"
    key                  = "dev_tfstate_key"
  }
}

provider "azurerm" {
  features {}
}

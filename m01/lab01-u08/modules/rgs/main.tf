terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.22"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

variable "rg_name" {
  type    = string
  default = "ContosoResourceGroup"
}


resource "azurerm_resource_group" "vnet_rg" {
  name     = "ContosoResourceGroup"
  location = "eastus"
}

resource "azurerm_resource_group" "nwrg" {
  name     = "NetworkWatcherRG"
  location = "eastus"
}

output "vnet_rg_name" {
  value = azurerm_resource_group.vnet_rg.name
}

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

  }
  skip_provider_registration = true
}

variable "rg_name" {
  type = string
  default = "ContosoResourceGroup"
}

variable "core_services_vnet_subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
  default = {
    "GatewaySubnet" = {
      name = "GatewaySubnet"
      cidr = "10.20.0.0/27"
    }
    "SharedServicesSubnet" = {
      name = "SharedServicesSubnet"
      cidr = "10.20.10.0/24"
    }
    "DatabaseSubnet" = {
      name = "DatabaseSubnet"
      cidr = "10.20.20.0/24"
    }
    "PublicWebServiceSubnet" = {
      name = "PublicWebServiceSubnet"
      cidr = "10.20.30.0/24"
    }
  }
}

variable "manufacturing_vnet_subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
  default = {
    "ManufacturingSystemSubnet" = {
      name = "ManufacturingSystemSubnet"
      cidr = "10.30.10.0/24"
    }
    "SensorSubnet1" = {
      name = "SensorSubnet1"
      cidr = "10.30.20.0/24"
    }
    "SensorSubnet2" = {
      name = "SensorSubnet2"
      cidr = "10.30.21.0/24"
    }
    "SensorSubnet3" = {
      name = "PublicWebServiceSubnet"
      cidr = "10.30.22.0/24"
    }
  }
}

variable "research_vnet_subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
  default = {
    "ResearchSystemSubnet" = {
      name = "ResearchSystemSubnet"
      cidr = "10.40.0.0/24"
    }
  }
}

resource "azurerm_resource_group" "vnet_rg" {
    name = "ContosoResourceGroup"
    location = "eastus"
}

resource "azurerm_virtual_network" "core_services_vnet" {
  name                = "CoreServicesVnet"
  location            = "East US"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "core_services_vnet_subnet" {
  for_each             = var.core_services_vnet_subnets
  resource_group_name  = azurerm_virtual_network.core_services_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.core_services_vnet.name
  name                 = each.value["name"]
  address_prefixes     = [each.value["cidr"]]
}

resource "azurerm_virtual_network" "manufacturing_vnet" {
  name                = "ManufacturingVnet"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "manufacturing_vnet_subnet" {
  for_each             = var.manufacturing_vnet_subnets
  resource_group_name  = azurerm_virtual_network.manufacturing_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.manufacturing_vnet.name
  name                 = each.value["name"]
  address_prefixes     = [each.value["cidr"]]
}

resource "azurerm_virtual_network" "resaerch_vnet" {
  name                = "ResearchVnet"
  location            = "Southeast Asia"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  address_space       = ["10.40.0.0/16"]
}

resource "azurerm_subnet" "research_vnet_subnet" {
  for_each             = var.research_vnet_subnets
  resource_group_name  = azurerm_virtual_network.resaerch_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.resaerch_vnet.name
  name                 = each.value["name"]
  address_prefixes     = [each.value["cidr"]]
}

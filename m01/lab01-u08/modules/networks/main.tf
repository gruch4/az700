variable "rg_name" {
  type    = string
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


resource "azurerm_virtual_network" "core_services_vnet" {
  name                = "CoreServicesVnet"
  location            = "East US"
  resource_group_name = var.rg_name
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
  resource_group_name = var.rg_name
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
  resource_group_name = var.rg_name
  address_space       = ["10.40.0.0/16"]
}

resource "azurerm_subnet" "research_vnet_subnet" {
  for_each             = var.research_vnet_subnets
  resource_group_name  = azurerm_virtual_network.resaerch_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.resaerch_vnet.name
  name                 = each.value["name"]
  address_prefixes     = [each.value["cidr"]]
}

resource "azurerm_virtual_network_peering" "CoreServicesVnet-to-ManufacturingVnet" {
  name                         = "CoreServicesVnet-to-ManufacturingVnet"
  resource_group_name          = azurerm_virtual_network.core_services_vnet.resource_group_name
  virtual_network_name         = azurerm_virtual_network.core_services_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.manufacturing_vnet.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "ManufacturingVnet-to-CoreServicesVnet" {
  name                         = "ManufacturingVnet-to-CoreServicesVnet"
  resource_group_name          = azurerm_virtual_network.manufacturing_vnet.resource_group_name
  virtual_network_name         = azurerm_virtual_network.manufacturing_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.core_services_vnet.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
}


output "core_services_subnets_id" {
  value = {
    for id in keys(var.core_services_vnet_subnets) : id => azurerm_subnet.core_services_vnet_subnet[id].id
  }
  description = "List of subnets"
}

output "manufacturing_subnets_id" {
  value = {
    for id in keys(var.manufacturing_vnet_subnets) : id => azurerm_subnet.manufacturing_vnet_subnet[id].id
  }
  description = "List of Manfucaturing subnets"
}


output "vnet_ids" {
  value = {
    "cs_vnet" = azurerm_virtual_network.core_services_vnet.id
    "man_vnet" = azurerm_virtual_network.manufacturing_vnet.id
    "rd_vnet" = azurerm_virtual_network.resaerch_vnet.id
  }
}

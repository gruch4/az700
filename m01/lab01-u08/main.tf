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
  type    = string
  default = "ContosoResourceGroup"
}


module "rgs" {
  source = "./modules/rgs"

  rg_name = var.rg_name
}

module "network" {
  source = "./modules/networks"

  rg_name = module.rgs.vnet_rg_name

  depends_on = [
    module.rgs
  ]
}

module "dns" {
  source = "./modules/dns"

  rg_name  = module.rgs.vnet_rg_name
  vent_ids = module.network.vnet_ids

  depends_on = [
    module.network
  ]
}

module "vms" {
  source = "./modules/vms"

  subnet_ids      = module.network.core_services_subnets_id
  man_subnets_ids = module.network.manufacturing_subnets_id
  rg_name         = module.rgs.vnet_rg_name

  depends_on = [
    module.network, module.dns
  ]
}

output "test" {
  value = module.network.manufacturing_subnets_id
}

# output "core_services_subnets_id" {
#   value = {
#     for id in keys(var.core_services_vnet_subnets) : id => azurerm_subnet.core_services_vnet_subnet[id].id
#   }
#   description = "List of subnets"
# }

# locals {
#   subnet_ids = {
#     for id in keys(var.core_services_vnet_subnets) : id => azurerm_subnet.core_services_vnet_subnet[id].id
#   }
# }



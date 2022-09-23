variable "rg_name" {
  type    = string
  default = "ContosoResourceGroup"
}

variable "vent_ids" {
  type = map
}



resource "azurerm_private_dns_zone" "contoso" {
  name                = "contoso.com"
  resource_group_name = var.rg_name

}

resource "azurerm_private_dns_zone_virtual_network_link" "cs_link" {
  name                  = "CoreServicesVnetLink"
  resource_group_name   = azurerm_private_dns_zone.contoso.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.contoso.name
  virtual_network_id    = var.vent_ids["cs_vnet"]
  registration_enabled  = true
  depends_on = [
    azurerm_private_dns_zone.contoso
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "manufacturing_link" {
  name                  = "ManufacturingVnetLink"
  resource_group_name   = azurerm_private_dns_zone.contoso.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.contoso.name
  virtual_network_id    = var.vent_ids["man_vnet"]
  registration_enabled  = true
  depends_on = [
    azurerm_private_dns_zone.contoso, azurerm_private_dns_zone_virtual_network_link.cs_link
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "research_link" {
  name                  = "ResearchVnetLink"
  resource_group_name   = azurerm_private_dns_zone.contoso.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.contoso.name
  virtual_network_id    = var.vent_ids["rd_vnet"]
  registration_enabled  = true
  depends_on = [
    azurerm_private_dns_zone.contoso, azurerm_private_dns_zone_virtual_network_link.manufacturing_link
  ]
}
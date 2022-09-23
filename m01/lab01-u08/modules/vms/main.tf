variable "rg_name" {
  type    = string
  default = "ContosoResourceGroup"
}

variable "subnet_ids" {
  type = map(any)
}

variable "man_subnets_ids" {
  type = map(any)
}

variable "vm_pass" {
  type      = string
  default   = "TestPa$$w0rd!"
  sensitive = true
}

resource "azurerm_public_ip" "testvm1_pip" {
  name                = "testvm1-pip"
  resource_group_name = var.rg_name
  location            = "eastus"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_network_interface" "testvm1_nic" {
  name                = "testvm1-nic"
  resource_group_name = var.rg_name
  location            = "eastus"

  ip_configuration {
    name = "ipconfig1"
    # subnet_ids = {for id in keys(var.core_services_vnet_subnets) : id => azurerm_subnet.core_services_vnet_subnet[id].id}
    subnet_id                     = var.subnet_ids["DatabaseSubnet"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testvm1_pip.id
  }
  depends_on = [
    azurerm_public_ip.testvm1_pip
  ]
}

resource "azurerm_network_security_group" "testvm1_nsg1" {
  name                = "testvm1-nsg"
  location            = "eastus"
  resource_group_name = var.rg_name
  security_rule = [{
    access                                     = "Allow"
    description                                = "Allow RDP from internet"
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "3389"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "default-allow-rdp"
    priority                                   = 1000
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }]
}

resource "azurerm_network_interface_security_group_association" "testvm1_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.testvm1_nic.id
  network_security_group_id = azurerm_network_security_group.testvm1_nsg1.id
}


resource "azurerm_windows_virtual_machine" "testvm1" {
  name                = "testvm1"
  resource_group_name = var.rg_name
  location            = "eastus"
  size                = "Standard_D2s_v3"
  admin_username      = "TestUser"
  admin_password      = var.vm_pass
  network_interface_ids = [
    azurerm_network_interface.testvm1_nic.id
  ]
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }
  depends_on = [
    azurerm_network_interface.testvm1_nic
  ]
}

resource "azurerm_public_ip" "testvm2_pip" {
  name                = "testvm2-pip"
  resource_group_name = var.rg_name
  location            = "eastus"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_network_interface" "testvm2_nic" {
  name                = "testvm2-nic"
  resource_group_name = var.rg_name
  location            = "eastus"

  ip_configuration {
    name = "ipconfig1"
    # subnet_ids = {for id in keys(var.core_services_vnet_subnets) : id => azurerm_subnet.core_services_vnet_subnet[id].id}
    subnet_id                     = var.subnet_ids["DatabaseSubnet"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testvm2_pip.id
  }
  depends_on = [
    azurerm_public_ip.testvm2_pip
  ]
}

resource "azurerm_network_security_group" "testvm2_nsg1" {
  name                = "testvm2-nsg"
  location            = "eastus"
  resource_group_name = var.rg_name
  security_rule = [{
    access                                     = "Allow"
    description                                = "Allow RDP from internet"
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "3389"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "default-allow-rdp"
    priority                                   = 1000
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }]
}

resource "azurerm_network_interface_security_group_association" "testvm2_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.testvm2_nic.id
  network_security_group_id = azurerm_network_security_group.testvm2_nsg1.id
}


resource "azurerm_windows_virtual_machine" "testvm2" {
  name                = "testvm2"
  resource_group_name = var.rg_name
  location            = "eastus"
  size                = "Standard_D2s_v3"
  admin_username      = "TestUser"
  admin_password      = var.vm_pass
  network_interface_ids = [
    azurerm_network_interface.testvm2_nic.id
  ]
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }
  depends_on = [
    azurerm_network_interface.testvm2_nic
  ]
}



resource "azurerm_public_ip" "manufacturingvm_pip" {
  name                = "manufacturing-pip"
  resource_group_name = var.rg_name
  location            = "westeurope"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_network_interface" "manufacturing_nic" {
  name                = "manufacturing-nic"
  resource_group_name = var.rg_name
  location            = "westeurope"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.man_subnets_ids["ManufacturingSystemSubnet"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.manufacturingvm_pip.id
  }
  depends_on = [
    azurerm_public_ip.manufacturingvm_pip
  ]
}

resource "azurerm_network_security_group" "manufacturingvm_nsg1" {
  name                = "manufacturingvm-nsg"
  location            = "westeurope"
  resource_group_name = var.rg_name
  security_rule = [{
    access                                     = "Allow"
    description                                = "Allow RDP from internet"
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "3389"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "default-allow-rdp"
    priority                                   = 1000
    protocol                                   = "Tcp"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }]
}

resource "azurerm_network_interface_security_group_association" "manufacturing_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.manufacturing_nic.id
  network_security_group_id = azurerm_network_security_group.manufacturingvm_nsg1.id
}


resource "azurerm_windows_virtual_machine" "manufacturingvm" {
  name                = "ManufacturingVM"
  resource_group_name = var.rg_name
  location            = "westeurope"
  size                = "Standard_D2s_v3"
  admin_username      = "TestUser"
  admin_password      = var.vm_pass
  network_interface_ids = [
    azurerm_network_interface.manufacturing_nic.id
  ]
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }
  depends_on = [
    azurerm_network_interface.manufacturing_nic
  ]
}

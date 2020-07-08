provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main_rg" {
  name     = "${var.project_name}-rg"
  location = var.default_location

  tags = {
    environment = "development"
    project     = "learn terraform"
  }
}

resource "azurerm_virtual_network" "infra_vnet" {
  name                = "${var.project_name}-infra-vnet"
  location            = var.default_location
  resource_group_name = azurerm_resource_group.main_rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "development"
    project     = "learn terraform"
  }
}

resource "azurerm_virtual_network" "web_vnet" {
  name                = "${var.project_name}-web-vnet"
  location            = var.default_location
  resource_group_name = azurerm_resource_group.main_rg.name
  address_space       = ["10.1.0.0/16"]

  tags = {
    environment = "development"
    project     = "learn terraform"
  }
}

resource "azurerm_subnet" "infra_subnet" {
  name                 = "${var.main_environment}-subnet"
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.infra_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "web_subnet" {
  name                 = "${var.web_environment}-subnet"
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.web_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_peering" "main_to_web_peering" {
  name                      = "main-to-web-peering"
  resource_group_name       = azurerm_resource_group.main_rg.name
  virtual_network_name      = azurerm_virtual_network.infra_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.web_vnet.id
}

resource "azurerm_virtual_network_peering" "web_to_main_peering" {
  name                      = "main-to-web-peering"
  resource_group_name       = azurerm_resource_group.main_rg.name
  virtual_network_name      = azurerm_virtual_network.web_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.infra_vnet.id
}

resource "azurerm_public_ip" "infra_vm_pip" {
  name                = "${var.main_environment}-vm-pip"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = var.default_location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "infra_vm_interface" {
  name                = "${var.main_environment}-vm-int"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = var.default_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.infra_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.infra_vm_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "infra_vm" {
  name                            = "${var.main_environment}-vm"
  resource_group_name             = azurerm_resource_group.main_rg.name
  location                        = var.default_location
  size                            = "Standard_B2s"
  admin_username                  = "sysadmin"
  admin_password                  = "Password_123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.infra_vm_interface.id
  ]

  os_disk {
    name                 = "${var.main_environment}-vm-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }

  source_image_reference {
    publisher = "Openlogic"
    offer     = "CentOS"
    sku       = "8_1"
    version   = "latest"
  }

}

resource "azurerm_network_interface" "web_vm_interface" {
  name                = "${var.web_environment}-vm-int"
  resource_group_name = azurerm_resource_group.main_rg.name
  location            = var.default_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web_vm" {
  name                            = "${var.web_environment}-vm"
  resource_group_name             = azurerm_resource_group.main_rg.name
  location                        = var.default_location
  size                            = "Standard_B2s"
  admin_username                  = "sysadmin"
  admin_password                  = "Password_123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.web_vm_interface.id
  ]

  os_disk {
    name                 = "${var.web_environment}-vm-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }

  source_image_reference {
    publisher = "Openlogic"
    offer     = "CentOS"
    sku       = "8_1"
    version   = "latest"
  }

}

output "Infra_VM_Public_IP" {
  value = azurerm_public_ip.infra_vm_pip.ip_address
  description = "This is the IP you connect too with SSH"
}

output "Web_VM_Private_IP" {
  value = azurerm_linux_virtual_machine.web_vm.private_ip_address
  description = "This is the IP you connect too with SSH"
}


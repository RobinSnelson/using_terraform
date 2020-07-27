provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "jenkins_rg" {
  name     = "${var.project_name}-rg"
  location = var.location

  tags = {
    "Environment" = "Jenkins"
    "Type"        = "Resource Group"
    "Purpose"     = "Study"
  }
}

resource "azurerm_virtual_network" "jenkins_vnet" {
  name                = "${var.project_name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name
  address_space = [
    "${var.vnet_address_space}"
  ]

  tags = {
    "Environment" = "Jenkins"
    "Type"        = "Virtual Network"
    "Purpose"     = "Study"
  }

}

resource "azurerm_subnet" "jenkins_subnet" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.jenkins_rg.name
  virtual_network_name = azurerm_virtual_network.jenkins_vnet.name

  address_prefixes = [
    "${var.subnet_address_prefix}"
  ]

}

resource "azurerm_public_ip" "jenkinsServerPublicIP" {
  name                = "${var.project_name}-vm-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name
  allocation_method   = "Static"

  tags = {
    "Environment" = "Jenkins"
    "Type"        = "Public IP"
    "Purpose"     = "Study"
  }
}

resource "azurerm_network_interface" "jenkinsServerNIC_ID" {
  name                = "${var.project_name}-vm-int"
  location            = var.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name

  ip_configuration {
    name                          = "JenkinsIPConfig"
    subnet_id                     = azurerm_subnet.jenkins_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkinsServerPublicIP.id
  }

  tags = {
    "Environment" = "Jenkins"
    "Type"        = "Network Interface"
    "Purpose"     = "Study"
  }
}
resource "azurerm_linux_virtual_machine" "jenkinsServerVM" {
  name                = "${var.project_name}-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name
  size                = "Standard_B2s"
  provision_vm_agent  = true
  admin_username      = "sysadmin"


  network_interface_ids = [
    "${azurerm_network_interface.jenkinsServerNIC_ID.id}"
  ]

  admin_ssh_key {
    username   = "sysadmin"
    public_key = var.public_key
  }

  os_disk {
    name                 = "${var.project_name}-vm-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    "Environment" = "Jenkins"
    "Type"        = "Virtual Machine"
    "Purpose"     = "Study"
  }
}

resource "azurerm_virtual_machine_extension" "jenkins_extension" {
  name                 = "Install-Jenkins"
  virtual_machine_id   = azurerm_linux_virtual_machine.jenkinsServerVM.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
      "fileUris" : ["https://raw.githubusercontent.com/RobinSnelson/azuredevelopment/master/snippets/installjenkins.sh"],
      "commandToExecute" : "bash installjenkins.sh"
  }
  SETTINGS

  tags = {
    "Environment" = "Jenkins"
    "Type"        = "Extension"
    "Purpose"     = "Study"
  }
}

output "ServerIP" {
  value = azurerm_public_ip.jenkinsServerPublicIP.ip_address
}

output "ServerUrl" {
  value = "http://${azurerm_public_ip.jenkinsServerPublicIP.ip_address}:8080"
}
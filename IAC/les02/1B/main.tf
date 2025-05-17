terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "iacVNet"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = "s1190828"
}

resource "azurerm_subnet" "subnet" {
  name                 = "iacSubnet"
  resource_group_name  = "s1190828"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "iacNIC"
  location            = "westeurope"
  resource_group_name = "s1190828"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ubuntuVM"
  resource_group_name = "s1190828"
  location            = "westeurope"
  size                = "Standard_B2ats_v2"
  admin_username      = "student"

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "student"
    public_key = file("~/.ssh/id_rsa_azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  disable_password_authentication = true
}

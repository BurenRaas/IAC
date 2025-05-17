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
  subscription_id = "7c2cf771-1067-4e56-9047-4a218905ddaf"
}

resource "azurerm_resource_group" "rg" {
  name     = "s1190828"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "iacVNet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "iacSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  count               = 1
  name                = "iacPublicIP-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count               = 1
  name                = "iacNIC-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = 1
  name                = "iacVM-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B2ats_v2"
  admin_username      = "iac"

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "s1190828@student.windesheim.nl"
    public_key = file("~/.ssh/id_rsa_azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "iacOSDisk-${count.index}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(file("cloud-init.yml"))

  disable_password_authentication = true
}

resource "local_file" "vm_ip" {
  content  = azurerm_public_ip.pip[0].ip_address
  filename = "vm-ip.txt"
}


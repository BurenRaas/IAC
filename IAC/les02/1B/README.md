# s1190828 Ruben Baas
Opdracht 1B – Ubuntu VM in Azure (Standard_B2ats_v2)

## Bronnen
- Microsoft: [Basv2 sizes series](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/basv2-series?tabs=sizebasic)  
- GitHub: [azurerm Linux VM voorbeeld](https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/virtual-machines/linux/provisioner)
AI prompt: genereer op basis van deze code een README.md


## 1. Provider en abonnement

```hcl
provider "azurerm" {
  features {}
}
```

Deze provider is nodig om Terraform met Azure te laten communiceren. De `features {}` is verplicht vanaf versie 2.x en hoger. Het abonnement wordt automatisch opgepakt via `az login`.

---

## 2. Virtual Network en Subnet

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "iacVNet"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = "s1190828"
}
```

```hcl
resource "azurerm_subnet" "subnet" {
  name                 = "iacSubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = "s1190828"
}
```

We maken een eigen netwerk (`vnet`) met een subnet waarin de VM komt. Het adresbereik is intern (`10.0.x.x`) en heeft geen internettoegang.

---

## 3. Netwerkinterface zonder public IP

```hcl
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
```

Deze NIC koppelt de VM aan het subnet, maar zonder public IP. Dit is geschikt voor interne VM’s die niet direct benaderbaar hoeven te zijn.

---

## 4. Ubuntu VM (Standard_B2ats_v2)

```hcl
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

  disable_password_authentication = true
```

Deze resource creëert de VM op basis van de `Standard_B2ats_v2` size. De gebruiker `student` wordt aangemaakt met alleen SSH key-login. Geen wachtwoordtoegang mogelijk.

---

## 5. OS en image

```hcl
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
```

We gebruiken een officiële Ubuntu 20.04 LTS image. De OS disk is standaard en niet versleuteld.

---


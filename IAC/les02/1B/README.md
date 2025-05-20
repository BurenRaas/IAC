# Opdracht 1B – Azure VM Deployment met Terraform
Ruben Baas s1190828

## Beschrijving van de opdracht

In deze opdracht wordt met behulp van Terraform een virtuele machine (VM) uitgerold in Microsoft Azure. Dit gebeurt door het aanmaken van een virtueel netwerk, subnet, netwerkinterface en een Ubuntu Linux VM. Deze VM is via SSH toegankelijk en vormt de basis voor verdere automatisering.

---

## Uitleg van de code

### Bestand: `main.tf`

Dit bestand bevat de volledige definitie van de infrastructuur die uitgerold wordt met Terraform. Hieronder een overzicht van de belangrijkste onderdelen:

- **Provider block:**
  ```hcl
  terraform {
    required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.0"
      }
    }
  }

  provider "azurerm" {
    features {}
    subscription_id = "..." # Jouw Azure subscription
  }
  ```
  Dit configureert Terraform om gebruik te maken van Azure via de `azurerm` provider.

- **Virtueel netwerk, subnet en NIC:**
  ```hcl
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
  ```
  Hiermee wordt een virtueel netwerk (VNet) aangemaakt met adresruimte `10.0.0.0/16`, en een subnet daarin met `10.0.1.0/24`. Deze netwerkstructuur is nodig zodat de VM met andere services in Azure kan communiceren binnen een beveiligd IP-bereik.
  De NIC verbindt de VM met het subnet. De instelling `private_ip_address_allocation = "Dynamic"` zorgt ervoor dat het interne IP automatisch wordt toegewezen.

- **Linux VM:**
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
    public_key = file("~/.ssh/iac.pub")
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
  ```

 - **Authenticatie via SSH:** alleen toegang met je publieke sleutel (`~/.ssh/iac.pub`), wachtwoordlogin is uitgeschakeld.
  - **OS disk:** wordt standaard aangemaakt met SSD (`Standard_LRS`) en caching aan.
  - **Image:** Er wordt gebruik gemaakt van een officiële Canonical Ubuntu-image.
  - **VM grootte:** De `Standard_B2ats_v2` is een voordelige VM met 2 vCPU’s en 4 GB RAM, geschikt voor testomgevingen.

---

## Uitvoeren van de code

### Vereisten

- Terrafrom
- Azure CLI (voor inloggen)
- Een SSH keypair 


### Stappen

1. **Login op Azure (éénmalig)**
   ```bash
   az login
   ```

2. **Initialiseer Terraform directory**
   ```bash
   terraform init
   ```

3. **Bekijk de geplande acties**
   ```bash
   terraform plan
   ```

4. **Voer de configuratie uit**
   ```bash
   terraform apply
   ```

5. **(Optioneel) Verwijderen van de infrastructuur**
   ```bash
   terraform destroy
   ```

---

## Bronnen (indien AI niet is gebruikt)

-Terraform documentatie: [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- Microsoft Basv2: [Basv2 sizes series](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/basv2-series?tabs=sizebasic)  
- Code voorbeelden (beter goed gejat dan slecht bedacht): [azurerm Linux VM voorbeeld](https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/virtual-machines/linux/provisioner)
- AI pompt: Maak voor opdracht 1B een readme.MD volgens de beoordelingsmatrix. Voeg uitleg toe over de code. (opdracht en code aan chat  toegevoegd) https://chatgpt.com/share/682b6a15-bbcc-8007-8ee8-3520bbfae328



---


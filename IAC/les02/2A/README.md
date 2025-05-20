# Opdracht 2A – Week 2    
s1190828 Ruben Baas

---

## Beschrijving van de opdracht

In deze opdracht wordt Terraform gebruikt om meerdere virtuele machines automatisch uit te rollen op een lokale ESXi-server. De machines worden geconfigureerd via cloud-init, waarmee een gebruiker en basissoftware worden ingesteld. Daarnaast worden de IP-adressen van de uitgerolde VM's verzameld in één tekstbestand. Het doel is om kennis te maken met Infrastructure as Code (IaC) en het automatiseren van VM-provisioning.

---

## Gebruikte bronnen  
- [Terraform ESXi CloudInit code voorbeeld](https://github.com/josenk/terraform-provider-esxi/tree/master/examples/05%20CloudInit%20and%20Templates)  
- [Terraform Azure VM basic SSH code voorbeeld](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/virtual-machines/linux/basic-ssh/main.tf)  
- [Cloud-init documentatie configuration data files](https://cloudinit.readthedocs.io/en/latest/tutorial/qemu.html#define-the-configuration-data-files)  
- [Ansible inventory file via Terraform medium.com](https://medium.com/@rajeshshukla_49087/ansible-inventory-file-using-terraform-b305db3ead2)  
- Lesstof: *Week 2 - Hello, Terraform!* via leren.windesheim.nl  
- **AI Prompts:**
  - "met terraform en cloud-init, hoe krijg ik elk IP in een tekst bestand?"
  - "kan ik ervoor zorgen dat de IP's in 1 bestand terecht komen?"
  - "genereer op basis van deze code een README.md"
https://chatgpt.com/share/682b6fd3-69f4-8007-8801-15a8e2bd56a9

---

## Functionaliteit en configuratie  

### Uitrollen van VM’s op ESXi  
Met de `terraform-provider-esxi` worden 3 VM’s uitgerold op de ESXi-server `192.168.20.14`:

- **2x Webservers**: `webserver-1`, `webserver-2`  
- **1x Databaseserver**: `databaseserver`  

**Specificaties per VM:**
- OS: Ubuntu 24.04 (via OVA Cloud Image)
- 1 vCPU
- 2048 MB RAM
- Cloud-init configuratie voor user en packages
- Automatisch unieke naamgeving via `count.index`

#### Voorbeeld Terraform-code (webserver):

```hcl
resource "esxi_guest" "webserver" {
  count        = 2
  guest_name   = "webserver-${count.index + 1}"
  disk_store   = "DS01"
  ovf_source   = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.ova"
  memsize      = 2048
  numvcpus     = 1
  power        = "on"

  network_interfaces {
    virtual_network = "VM Network"
  }

  guestinfo = {
    "userdata"          = filebase64("userdata.yaml")
    "userdata.encoding" = "base64"
  }
}
```

---

### Cloud-init configuratie (`userdata.yaml`)  

```yaml
#cloud-config
users:
  - name: student
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1...<key hier>

packages:
  - wget
  - ntpdate
```

Deze configuratie wordt met base64 meegegeven aan de VM via `guestinfo`.

---

### IP-adressen verzamelen  

Na de deployment worden de IP-adressen van de servers automatisch opgeslagen in `serverips.txt`:

```hcl
resource "local_file" "all_ips" {
  content  = join("\n", concat(
    esxi_guest.webserver[*].ip_address,
    [esxi_guest.databaseserver.ip_address]
  ))
  filename = "${path.module}/serverips.txt"
}
```

Voorbeeldoutput:
```
192.168.20.21
192.168.20.22
192.168.20.23
```

---

## Uitvoeren van de code  

Zorg dat je Terraform en toegang tot de ESXi-host hebt. Gebruik onderstaande stappen:

```bash
terraform init
terraform plan
terraform apply
```

Na succesvolle deployment zijn de IP's te vinden in `serverips.txt`.

---


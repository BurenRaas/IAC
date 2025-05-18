# s1190828 Ruben Baas
Opdracht 2A week 2

## Gebruikte bronnen:
Repo terraform-provider-esxi/examples/05 CloudInit and Templates/ - https://github.com/josenk/terraform-provider-esxi/tree/master/examples/05%20CloudInit%20and%20Templates
Repo terraform-provider-azurerm/examples/virtual-machines/linux/basic-ssh - https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/virtual-machines/linux/basic-ssh/main.tf
Cloud-init documentation - https://cloudinit.readthedocs.io/en/latest/tutorial/qemu.html#define-the-configuration-data-files
Ansible inventory file using terraform - https://medium.com/@rajeshshukla_49087/ansible-inventory-file-using-terraform-b305db3ead2
Lesstof week 2 - Week 2 - Hello, Terraform! @ leren.windewheim.nl
AI prompt: genereer op basis van deze code een README.md
AI prompt: met terraform en cloud-init, hoe krijg ik elk IP in een tekst bestand?
AI prompt: kan ik ervoor zorgen dat de ips in 1 bestand terecht komen?

## Functionaliteit en configuratie

### VM's uitrollen op ESXi

Met onderstaande code worden 3 VM’s uitgerold via de `josenk/esxi` provider:

- **2x webserver** met namen `webserver-1` en `webserver-2`
- **1x databaseserver** met naam `databaseserver`

Elke VM krijgt:
- 1 vCPU
- 2048 MB RAM
- Ubuntu 24.04 via cloud-image (.ova)
- apparte vm naam door count.index + 1

```hcl
#Web servers
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

#DB server
resource "esxi_guest" "databaseserver" {
  guest_name   = "databaseserver"
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

### cloud-init configuratie

De gebruikersconfiguratie wordt uitgevoerd via `userdata.yaml`. Hierin:
- Wordt gebruiker `student` aangemaakt
- Met `sudo`-rechten zonder wachtwoord
- Wordt een ED25519 SSH-sleutel geplaatst
- Worden de pakketten `wget` en `ntpdate` geïnstalleerd

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

De cloud-init wordt meegegeven via het `guestinfo`-mechanisme:

```hcl
guestinfo = {
  "userdata"          = filebase64("userdata.yaml")
  "userdata.encoding" = "base64"
}
```

---


### IP-adressen verzamelen in één bestand

Na deployment worden de IP-adressen automatisch verzameld en opgeslagen in één tekstbestand via de `local_file` resource:

```hcl
resource "local_file" "all_ips" {
  content  = join("\n", concat(
    esxi_guest.webserver[*].ip_address,
    [esxi_guest.databaseserver.ip_address]
  ))
  filename = "${path.module}/serverips.txt"
}
```

Resultaat in `serverips.txt`:
```
192.168.20.21
192.168.20.22
192.168.20.23
```

---
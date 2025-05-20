# Opdracht 2B – Azure VM Deployment met Terraform & Cloud-init
s1190828 Ruben Baas  

---

## Overzicht

Deze opdracht betreft het automatisch uitrollen van twee Ubuntu 20.04 VM’s in Azure met behulp van Terraform en Cloud-init. De authenticatie gebeurt via een ED25519 SSH-sleutel. De infrastructuur is beschreven in code (Infrastructure as Code, IaC), en de cloud-init configuratie zorgt voor de basisconfiguratie van de gebruiker binnen de VM’s.

---

## Inhoud & Configuratie

- **Provider:** `azurerm` (versie `~> 4.0`)
- **VM type:** `Standard_B2ats_v2`
- **Image:** Ubuntu 20.04 LTS (Canonical)
- **Aantal VM’s:** 2
- **Authenticatie:** ED25519 SSH key (`iac.pub`)
- **Cloud-init gebruiker:** `iac`
- **Regio:** `westeurope`
- **Resource Group:** `s1190828` (via `data`-block opgehaald)
- **Netwerk:**  
  - Virtual Network: `2bvnet`  
  - Subnet: `2bsubnet`  
  - IP's: 2 dynamische private IP’s, 2 public IP’s

---

## Cloud-init configuratie (`cloud-init.yml`)

```yaml
#cloud-config
users:
  - name: iac
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL58jaxD3fXQPm5zm7KdRJ0vMFsC1a/BnCtDgspeCbwg student@s1190828-ubuntu

write_files:
  - path: /home/iac/hello.txt
    content: |
      Hello World
```

---

## SSH-key configuratie in Terraform

```hcl
admin_ssh_key {
  username   = "iac"
  public_key = file("~/.ssh/iac.pub")
}
```

---

## Output naar bestand

De publieke IP-adressen van de twee VM’s worden lokaal opgeslagen in een tekstbestand:

```hcl
resource "local_file" "azure_ips" {
  content  = join("\n", azurerm_public_ip.pip[*].ip_address)
  filename = "${path.module}/azure-ips.txt"
}
```

---

## Resource Group via `data` block

```hcl
data "azurerm_resource_group" "rg" {
  name = "s1190828"
}
```

---

## Uitvoeren van de code

Voor het uitrollen van deze infrastructuur:

```bash
terraform init
terraform plan
terraform apply
```

Zorg dat je ingelogd bent in Azure met `az login` en dat je abonnement correct is ingesteld.


---

## Bronnen

- [Cloud-init write_files documentatie](https://cloudinit.readthedocs.io/en/latest/reference/yaml_examples/write_files.html#append-content-to-file)  
- [Terraform azurerm_resource_group data source](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)  
- [Terraform  SSH voorbeeld code](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/virtual-machines/linux/basic-ssh/main.tf)
- AI prompts: maak van deze code een README.md
waarom werkt mijn SSH key niet in Azure?
https://chatgpt.com/share/682b711d-fb58-8007-bc98-8125debbd393
---


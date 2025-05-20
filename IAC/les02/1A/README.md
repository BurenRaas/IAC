# Opdracht 1A – VM Deployen met Terraform op ESXi
Ruben Baas s1190828

## Beschrijving

Deze opdracht maakt gebruik van Terraform om een virtuele machine (VM) te deployen op een lokale ESXi-host. De VM wordt automatisch opgestart en probeert via netwerk te booten vanaf een Ubuntu 24.04 cloud-image (.ova).

## Bestanden

- `main.tf`: Bevat de definitie van de provider (ESXi) en de configuratie van de VM.
- `variables.tf`: Hierin staan variabelen zoals gebruikersnaam, wachtwoord en netwerkpoortinstellingen.
- `versions.tf`: Definieert de benodigde Terraform-versie en de vereiste provider.

## Voorwaarden

- Toegang tot een ESXi-server op IP `192.168.20.14`.
- De datastore `DS01` moet bestaan.
- Het virtuele netwerk moet `VM Network` heten.
- De `terraform-provider-esxi` moet beschikbaar zijn.
- Internettoegang vanaf de ESXi-host om de OVA te downloaden.

## Stappen om uit te voeren

1. **Terraform initialiseren**  
   Initialiseert de provider en laadt benodigde modules.

   ```bash
   terraform init
   ```

2. **Plan genereren**  
   Controleert wat Terraform gaat uitvoeren.

   ```bash
   terraform plan
   ```

3. **Deploy uitvoeren**  
   Maakt de VM aan op de ESXi-host en start deze.

   ```bash
   terraform apply
   ```

4. **Inloggegevens ingeven (indien nodig)**  
   Als het `esxi_password` niet is ingevuld, vraagt Terraform hier om tijdens het uitvoeren van `apply`.


## Bronvermelding

- Terraform ESXi Provider:  
  Laatste versie van provider: https://registry.terraform.io/providers/josenk/esxi  
  Code voorbeelden:  https://github.com/josenk/terraform-provider-esxi
- AI prompt: maak een readme.md voor opdracht 1b (opdracht en code aan chat  toegevoegd)
 https://chatgpt.com/share/682b66be-3aa4-8007-86f0-cdc82487a127


resource "local_file" "azure_ips" {
  content  = join("\n", azurerm_public_ip.pip[*].ip_address)
  filename = "${path.module}/azure-ips.txt"
}

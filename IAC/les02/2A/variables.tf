#
#  See https://www.terraform.io/intro/getting-started/variables.html for more details.
#

#  Change these defaults to fit your needs!


variable "esxi_hostname" {
  default = "192.168.20.14"
}

variable "esxi_hostport" {
  default = "22"
}

variable "esxi_hostssl" {
  default = "443"
}

variable "esxi_username" {
  default = "root"
}

variable "esxi_password" { # Unspecified will prompt 
}

variable "vmIP" {
  default = "192.168.20.14/24"
}

variable "vmGateway" {
  default = "192.168.20.1"
}


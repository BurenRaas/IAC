#########################################
#  ESXI Provider host/login details
#########################################
#
#   Use of variables here to hide/move the variables to a separate file
#
provider "esxi" {
  esxi_hostname = "192.168.20.14"
  esxi_hostport = "22"
  esxi_hostssl  = "443"
  esxi_username = "root"
  esxi_password = var.esxi_password
}

#########################################
#  ESXI Guest resource
#########################################
#
#  This Guest VM is "bare-metal".   It will be powered on by default
#  by terraform, but it will not boot to any OS.   It will however attempt
#  to network boot.
#

resource "esxi_guest" "vmtest01" {
  guest_name = "vmtest01" # Required, Specify the Guest Name
  disk_store = "DS01"   # Required, Specify an existing Disk Store
  network_interfaces {
    virtual_network = "VM Network" # Required for each network interface, Specify the Virtual Network name.
  }
  guestos = "ubuntu-x64"
  memsize            = "2048"
  numvcpus           = "2"
  power              = "on"
}


variable "resource_group_location" {
  default     = "northcentralus"
  description = "Location of the resource group."
}
variable "resource_group" {
  default     = "rd7task8"
  description = "Current resource group to work task8"
}
variable "resource_virtual_network" {
  default     = "vnet-task8"
  description = "Virtual Network for this task"
}
variable "resource_subnet" {
  default     = "snet-internal"
  description = "Internal subnet for background operations"
}
variable "resource_network_interface" {
  default     = "nic-task8"
  description = "Virtual Interface"
}
variable "resource_public_ip" {
  default     = "pip-publicJump"
  description = "Dynamic public IP for jump VM"
}
variable "resource_linux_virtual_machine_public" {
  default     = "vm-publicJump"
  description = "Public VM to jump inside the internal network"
}
variable "resource_nsg_ssh" {
  default     = "nsg-ssh"
  description = "Resource group for our inbound ssh rule"
}
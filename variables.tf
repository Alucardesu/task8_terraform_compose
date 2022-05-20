variable "resource_group_location" {
  default     = "centralus"
  description = "Location of the resource group."
}
variable "resource_group" {
  default     = "rd7task8-cus"
  description = "Current resource group to work task8"
}
variable "resource_virtual_network" {
  default     = "vnet-task8"
  description = "Virtual Network for this task"
}
variable "resource_subnet_public" {
  default     = "snet-public"
  description = "Internal subnet for jump operations"
}
variable "resource_subnet_backend" {
  default     = "snet-backend"
  description = "Internal subnet for background operations"
}
variable "resource_subnet_frontend" {
  default     = "snet-frontend"
  description = "Internal subnet for frontend operations"
}

variable "resource_network_interface_public" {
  default     = "nic-task8-public"
  description = "Virtual Interface for public jump VM"
}

variable "resource_network_interface_backend" {
  default     = "nic-task8-backend"
  description = "Virtual Interface for backend VMs"
}

variable "resource_network_interface_frontend" {
  default     = "nic-task8-frontend"
  description = "Virtual Interface for frontend VMs"
}

variable "resource_public_ip" {
  default     = "pip-publicJump"
  description = "Dynamic public IP for jump VM"
}
variable "resource_linux_virtual_machine_public" {
  default     = "vm-publicJump"
  description = "Public VM to jump inside the internal network"
}

variable "resource_linux_virtual_machine_backend" {
  default     = "vm-backend"
  description = "Private VM to be balanced internally only"
}

variable "resource_linux_virtual_machine_frontend" {
  default     = "vm-frontend"
  description = "Private VM to be balanced externally"
}

variable "resource_nsg_public" {
  default     = "nsg-public"
  description = "Network security group for our public VM"
}

variable "resource_nsg_backend" {
  default     = "nsg-backend"
  description = "Network security group for our backend LB"
}
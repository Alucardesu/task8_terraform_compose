resource "azurerm_resource_group" "rg" {
  name = var.resource_group
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.resource_virtual_network
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "backend" {
  name                 = var.resource_subnet_backend
  resource_group_name  = var.resource_group
  virtual_network_name = var.resource_virtual_network
  address_prefixes     = ["10.0.3.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "frontend" {
  name                 = var.resource_subnet_frontend
  resource_group_name  = var.resource_group
  virtual_network_name = var.resource_virtual_network
  address_prefixes     = ["10.0.4.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "vm-public" {
  name                 = var.resource_subnet_public
  resource_group_name  = var.resource_group
  virtual_network_name = var.resource_virtual_network
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#resource "local_file" "ssh-key" {
#  filename = "id_rsa"
#  content  = tls_private_key.ssh-key.private_key_pem
#}
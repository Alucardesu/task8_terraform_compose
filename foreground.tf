resource "azurerm_subnet" "foreground" {
  name                 = var.resource_subnet_foreground
  resource_group_name  = var.resource_group
  virtual_network_name = var.resource_virtual_network
  address_prefixes     = ["10.0.4.0/24"]
}
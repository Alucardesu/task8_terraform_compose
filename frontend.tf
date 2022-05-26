#resource "azurerm_public_ip" "frontend" {
#  name                = var.resource_public_ip_frontend
#  resource_group_name = var.resource_group
#  location            = var.resource_group_location
#  allocation_method   = "Static"
#  sku                 = "Standard"
#  depends_on          = [azurerm_resource_group.rg]
#}


#resource "azurerm_application_gateway" "agw-network" {
#  name                = "agw-frontend"
#  resource_group_name = var.resource_group
#  location            = var.resource_group_location
#
#  sku {
#    name     = "Standard_v2"
#    tier     = "Standard_v2"
#    capacity = 2
#  }
#
#  gateway_ip_configuration {
#    name      = "my-gateway-ip-configuration"
#    subnet_id = azurerm_subnet.frontend.id
#  }
#
#  frontend_port {
#    name = var.frontend_port_name
#    port = 80
#  }
#
#  frontend_ip_configuration {
#    name                 = var.frontend_ip_configuration_name
#    public_ip_address_id = azurerm_public_ip.frontend.id
#  }
#
#  backend_address_pool {
#    name = var.backend_address_pool_name
#  }
#
#  backend_http_settings {
#    name                  = var.http_setting_name
#    cookie_based_affinity = "Disabled"
#    path                  = "/"
#    port                  = 80
#    protocol              = "Http"
#    request_timeout       = 60
#  }
#
#  http_listener {
#    name                           = var.listener_name
#    frontend_ip_configuration_name = var.frontend_ip_configuration_name
#    frontend_port_name             = var.frontend_port_name
#    protocol                       = "Http"
#  }
#
#  request_routing_rule {
#    name                       = var.request_routing_rule_name
#    rule_type                  = "Basic"
#    http_listener_name         = var.listener_name
#    backend_address_pool_name  = var.backend_address_pool_name
#    backend_http_settings_name = var.http_setting_name
#  }
#}

resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "${var.resource_network_interface_frontend_backend}-${count.index}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ip-front-back-config"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "dynamic"
  }
  depends_on = [azurerm_subnet.backend]
}

#resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc01" {
#  count                   = 2
#  network_interface_id    = azurerm_network_interface.nic[count.index].id
#  ip_configuration_name   = "ip-front-back-config"
#  backend_address_pool_id = azurerm_application_gateway.agw-network.backend_address_pool[0].id
#
#  depends_on = [azurerm_network_interface.nic]
#}

resource "azurerm_linux_virtual_machine" "frontend" {
  count               = 2
  name                = "${var.resource_linux_virtual_machine_frontend}-${count.index}"
  resource_group_name = var.resource_group
  location            = var.resource_group_location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    applicationRole = "web-server"
  }

}

resource "azurerm_network_security_group" "nsg-frontend" {
  name                = var.resource_nsg_frontend
  location            = var.resource_group_location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "sg-allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "sg-allow-http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.rg]

}

resource "azurerm_network_interface_security_group_association" "association-frontend" {
  count                     = length(azurerm_network_interface.nic)
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-frontend.id
  depends_on                = [azurerm_resource_group.rg]
}

resource "azurerm_virtual_machine_extension" "frontend" {
  count                = 2
  name                 = "nginx-hostname-${count.index}"
  virtual_machine_id   = azurerm_linux_virtual_machine.frontend[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/Alucardesu/task8_terraform_compose/main/scripts/automate_nginx_v3.sh"],
        "commandToExecute": "./automate_nginx_v3.sh"
    }
SETTINGS

}
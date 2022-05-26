resource "azurerm_lb" "backend" {
  name                = "lb-backend"
  location            = var.resource_group_location
  resource_group_name = var.resource_group

  frontend_ip_configuration {
    name      = "localIPAddress"
    subnet_id = azurerm_subnet.backend.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.backend.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "backend" {
  loadbalancer_id     = azurerm_lb.backend.id
  name                = "ssh-running-probe"
  port                = 22
  resource_group_name = var.resource_group
}

resource "azurerm_lb_rule" "backend" {
  loadbalancer_id                = azurerm_lb.backend.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "localIPAddress"
  resource_group_name            = var.resource_group
  backend_address_pool_ids       = azurerm_lb_backend_address_pool.backend.*.id
  probe_id                       = azurerm_lb_probe.backend.id
}

resource "azurerm_network_interface" "backend" {
  count               = 2
  name                = "${var.resource_network_interface_backend}-${count.index}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ip-back-config"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_availability_set" "backend" {
  name                         = "avail-backend"
  location                     = var.resource_group_location
  resource_group_name          = var.resource_group
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  depends_on                   = [azurerm_resource_group.rg]
}

resource "azurerm_linux_virtual_machine" "backend" {
  count                 = 2
  name                  = "${var.resource_linux_virtual_machine_backend}-${count.index}"
  resource_group_name   = var.resource_group
  location              = var.resource_group_location
  availability_set_id   = azurerm_availability_set.backend.id
  size                  = "Standard_B1ls"
  admin_username        = "adminuser"
  network_interface_ids = [element(azurerm_network_interface.backend.*.id, count.index)]

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
    applicationRole = "bd-server"
  }

}

resource "azurerm_network_security_group" "nsg-backend" {
  name                = var.resource_nsg_backend
  location            = var.resource_group_location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "sg-allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "sg-allow-postgresql"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.rg]

}

resource "azurerm_network_interface_security_group_association" "association-backend" {
  count                     = length(azurerm_network_interface.backend)
  network_interface_id      = azurerm_network_interface.backend[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-backend.id
  depends_on                = [azurerm_resource_group.rg]
}

resource "azurerm_network_interface_backend_address_pool_association" "backend" {
  count                   = length(azurerm_network_interface.backend)
  network_interface_id    = azurerm_network_interface.backend[count.index].id
  ip_configuration_name   = "ip-back-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
}
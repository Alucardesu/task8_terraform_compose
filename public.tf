resource "azurerm_subnet" "vm-public" {
  name                 = var.resource_subnet_public
  resource_group_name  = var.resource_group
  virtual_network_name = var.resource_virtual_network
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vm-public" {
  name                = var.resource_public_ip
  resource_group_name = var.resource_group
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm-public" {
  name                = var.resource_network_interface_public
  location            = var.resource_group_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-public.id
  }
}

resource "azurerm_network_security_group" "nsg-public" {
  name                = var.resource_nsg_public
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
}

resource "azurerm_network_interface_security_group_association" "association-public" {
  network_interface_id      = azurerm_network_interface.vm-public.id
  network_security_group_id = azurerm_network_security_group.nsg-public.id
}

resource "azurerm_linux_virtual_machine" "vm-public" {
  name                = var.resource_linux_virtual_machine_public
  resource_group_name = var.resource_group
  location            = var.resource_group_location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm-public.id,
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
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
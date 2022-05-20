output "public_ip_address" {
  value = azurerm_linux_virtual_machine.vm-public.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.ssh-key.private_key_pem
  sensitive = true
}
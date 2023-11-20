output "public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_user" {
  value = azurerm_linux_virtual_machine.main.admin_username
}

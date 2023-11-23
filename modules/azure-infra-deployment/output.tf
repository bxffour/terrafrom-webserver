output "public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "vm_user" {
  value = azurerm_linux_virtual_machine.main.admin_username
}

output "ssh_public_key" {
  sensitive = true
  value = tls_private_key.ssh.public_key_openssh
}

output "ssh_private_key" {
  sensitive = true
  value = tls_private_key.ssh.private_key_openssh
}

output "kvname" {
  value = azurerm_key_vault.main.name
}
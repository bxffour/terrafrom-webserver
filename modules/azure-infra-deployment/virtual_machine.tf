resource "azurerm_virtual_network" "main" {
  name = "${local.cleansed_prefix}-network"
  location = var.location
  address_space = [ "10.0.0.0/16" ]
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name = "internal"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = [ "10.0.2.0/24" ]
  service_endpoints = [ "Microsoft.KeyVault" ]
}

resource "azurerm_public_ip" "main" {
  name = "${local.cleansed_prefix}-publicnet"
  resource_group_name = azurerm_resource_group.main.name
  location = var.location
  allocation_method = "Static"
}

resource "azurerm_network_security_group" "main" {
  name = "${local.cleansed_prefix}-securitygrp"
  resource_group_name = azurerm_resource_group.main.name
  location = var.location
}

resource "azurerm_network_security_rule" "ssh" {
  name = "ssh"
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  direction = "Inbound"
  priority = 1000
  protocol = "Tcp"
  access = "Allow"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "http" {
  name = "http"
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  direction = "Inbound"
  priority = 1001
  protocol = "Tcp"
  access = "Allow"
  source_port_range = "*"
  destination_port_range = "8080"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_interface" "main" {
  name = "${local.cleansed_prefix}-nic"  
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "tls_private_key" "ssh" {
 algorithm = "RSA"
 rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "main" {
  name = "${local.cleansed_prefix}-vm"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_network_interface.main.location
  size = "Standard_F2"
  admin_username = var.vm_admin_user

  network_interface_ids = [ azurerm_network_interface.main.id ]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username = var.vm_admin_user
    public_key = tls_private_key.ssh.public_key_openssh
  }

  source_image_reference {
    publisher = var.vm_image.publisher
    offer = var.vm_image.offer
    sku = var.vm_image.sku
    version = var.vm_image.version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
  }
}

variable "name_prefix" {
  type        = string
  description = "Name prefix to use for resources that need to be created (only lowercase characters and hyphens allowed)"
  default     = "shtan-app--"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type = string
  default = "West Europe"
}

variable "vm_admin_user" {
  type = string
  description = "Name of the admin user for the virtual machine"
  default = "shtech"
}

variable "vm_ssh_pubkey_path" {
  type = string
  description = "Path to the ssh pubkey used to authenticate the user"
}

variable "vm_image" {
  description = "This is the linux virtual machine image config"
  type = object({
    publisher = string
    offer = string 
    sku = string
    version = string
  })
}

locals {
    cleansed_prefix = replace(var.name_prefix, "/[^a-zA-Z0-9]+/", "")
}

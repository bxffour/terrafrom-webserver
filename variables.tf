variable "name_prefix" {
  type        = string
  description = "Name prefix to use for resources that need to be created (only lowercase characters and hyphens allowed)"
  default     = "shtan-app-"
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

variable "vm_image" {
  description = "This is the linux virtual machine image config"
  type = object({
    publisher = string
    offer = string 
    sku = string
    version = string
  })

  default = {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }
}

variable "app_version" {
  type = string
  description = "The version of the app to be installed on the vm"
  default = "0.2.0"

  validation {
    condition = can(regex("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$", var.app_version))
    error_message = "The version number must follow the Semantic Versioning syntax (MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD])."
  }
}

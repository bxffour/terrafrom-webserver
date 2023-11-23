terraform {
  backend "azurerm" {
    resource_group_name = "personal"
    storage_account_name = "terraformbxffour"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }

  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }

    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

locals {
  ssh_private_key_path = pathexpand("~/.ssh/shtan_id_rsa")
  ssh_public_key_path = pathexpand("~/.ssh/shtan_id_rsa.pub")
  playbook = "${path.module}/app-deploy-ansible/main.yml"
  # varsfile = "${path.module}/app-deploy-ansible/vars.yml"
  inventory = "${path.module}/app-deploy-ansible/inventory.ini"
}

module "az_infra" {
  source = "./modules/azure-infra-deployment"

  name_prefix = var.name_prefix
  location = var.location

  vm_admin_user = var.vm_admin_user
  vm_image = var.vm_image
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/ansible-inventory.tpl", {
    nodes = [ module.az_infra.public_ip ]
    ssh_priv_key = local.ssh_private_key_path
    ansible_ssh_user = module.az_infra.vm_user
  })

  filename = "${path.module}/app-deploy-ansible/inventory.ini"
  file_permission = "0644"
}

resource "local_sensitive_file" "vm_ssh_pubkey" {
  content = module.az_infra.ssh_public_key
  filename = local.ssh_public_key_path
  file_permission = "0600"
}

resource "local_sensitive_file" "vm_ssh_privkey" {
  content = module.az_infra.ssh_private_key
  filename = local.ssh_private_key_path
  file_permission = "0600"
}

resource "null_resource" "ansible_run" {
  depends_on = [ 
    local_file.ansible_inventory, 
    local_sensitive_file.vm_ssh_privkey, 
    local_sensitive_file.vm_ssh_pubkey,
    module.az_infra
  ]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ${local.playbook} -e kvname=${module.az_infra.kvname} -e app_version=${var.app_version} -i ${local.inventory}"
  }
}

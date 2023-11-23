# Define Terraform backend configuration for storing state files in Azure Storage.
terraform {
  backend "azurerm" {
    resource_group_name = "personal"
    storage_account_name = "terraformbxffour"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }

 # Declare required Terraform providers with versions.
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

# Define local variables for paths and file names.
locals {
  ssh_private_key_path = pathexpand("~/.ssh/shtan_id_rsa")
  ssh_public_key_path = pathexpand("~/.ssh/shtan_id_rsa.pub")
  playbook = "${path.module}/app-deploy-ansible/main.yml"
  inventory = "${path.module}/app-deploy-ansible/inventory.ini"
}

# Invoke the Azure infrastructure deployment module.
module "az_infra" {
  source = "./modules/azure-infra-deployment"

  name_prefix = var.name_prefix
  location = var.location

  vm_admin_user = var.vm_admin_user
  vm_image = var.vm_image
}

# Dynamically create ansible inventory file by injecting the ip address of the 
# provisioned vm, the vm admin user and the path to the ssh private key
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/ansible-inventory.tpl", {
    nodes = [ module.az_infra.public_ip ]
    ssh_priv_key = local.ssh_private_key_path
    ansible_ssh_user = module.az_infra.vm_user
  })

  filename = "${path.module}/app-deploy-ansible/inventory.ini"
  file_permission = "0644"
}

# Create local files for SSH key files.
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

# Define a null resource to run Ansible playbook after Azure infrastructure provisioning.
resource "null_resource" "ansible_run" {
  depends_on = [ 
    local_file.ansible_inventory, 
    local_sensitive_file.vm_ssh_privkey, 
    local_sensitive_file.vm_ssh_pubkey,
    module.az_infra
  ]

  # Use local-exec provisioner to execute Ansible playbook.
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ${local.playbook} -e kvname=${module.az_infra.kvname} -e app_version=${var.app_version} -i ${local.inventory}"
  }
}

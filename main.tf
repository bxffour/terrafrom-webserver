terraform {
  backend "azurerm" {
    resource_group_name = "personal"
    storage_account_name = "terraformbxffour"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }
}

module "az_infra" {
  source = "./modules/azure-infra-deployment"

  vm_image = {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/ansible-inventory.tpl", {
    nodes = [ module.az_infra.public_ip ]
    ssh_priv_key = "~/.ssh/id_rsa"
    ansible_ssh_user = module.az_infra.vm_user
  })

  filename = "${path.module}/app-deploy-ansible/inventory.ini"
  file_permission = "0644"
}

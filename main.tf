module "az_infra" {
  source = "./modules/azure-infra-deployment"

  vm_image = {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }
}

module "web-deploy" {
  source = "./modules/web-app"

  host = module.az_infra.public_ip
}

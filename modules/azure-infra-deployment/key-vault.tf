locals {
  key_vault_name = "${local.cleansed_prefix}${random_string.suffix.result}"
}

resource "azurerm_key_vault" "main" {
  name = local.key_vault_name
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}
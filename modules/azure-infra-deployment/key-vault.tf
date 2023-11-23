resource "azurerm_key_vault" "main" {
  name = "${local.cleansed_prefix}-keyvault"
  location = var.location
  resource_group_name = azurerm_resource_group.main.name
  enabled_for_disk_encryption = false
  tenant_id = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled = false
  enable_rbac_authorization = true

  sku_name = "standard"
}

resource "azurerm_role_assignment" "key_vault" {
  scope = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "main" {
  depends_on = [ azurerm_role_assignment.key_vault ]
  name = "gosecret"
  value = "Carpe diem. Seize the day, boys. Make your lives extraordinary. - Dead Poets Society"
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_role_assignment" "gosecret" {
  scope = azurerm_key_vault_secret.main.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id = azurerm_linux_virtual_machine.main.identity[0].principal_id
}

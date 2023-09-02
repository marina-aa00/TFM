//Keyvault access policy for the ARS vault
resource "azurerm_key_vault_access_policy" "keyvault_policy3" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_recovery_services_vault.ars-vault.identity[0].principal_id
  key_permissions = [
    "Get", "GetRotationPolicy","SetRotationPolicy", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Sign", "Verify","List","Backup"
  ]
  secret_permissions = [
    "Get", "List","Backup","Restore"
  ]
  depends_on = [
    azurerm_recovery_services_vault.ars-vault
  ]
}

//Keyvault access policy for the Backup Management Service
resource "azurerm_key_vault_access_policy" "keyvault_policy4" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.backup_mgmt_service_id
  key_permissions = [
      "Get", "List","Backup"
  ]
  secret_permissions = [
    "Get", "List","Backup"
  ]
}



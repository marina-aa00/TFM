
data "azurerm_client_config" "current" {
}


//Keyvault access policy for apppro-payin-01 which manages incoming payments
resource "azurerm_key_vault_access_policy" "keyvault_policy1" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_linux_web_app.webapp1.identity[0].principal_id
  secret_permissions = [
    "Get",
    "List",
    "Set"
  ]
}

//Keyvault access policy for security admin user
resource "azurerm_key_vault_access_policy" "keyvault_policyuseradmin" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  secret_permissions = [
    "Get","List","Set","Delete","Recover","Backup","Restore"
  ]
  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy","SetRotationPolicy","Encrypt","Decrypt","Sign","UnwrapKey","WrapKey","Verify"
  ]
}

//Keyvault access policy for employee user
resource "azurerm_key_vault_access_policy" "keyvault_policyemployee" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.principal_user_id
  secret_permissions = [
    "Get","List"
  ]
  key_permissions = [
    "Get", "List", "GetRotationPolicy","Encrypt","Decrypt","Sign","UnwrapKey","WrapKey","Verify"
  ]
}

//Keyvault access policy for apppro-payout-01 which manages outgoing payments 
resource "azurerm_key_vault_access_policy" "keyvault_policy2" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_linux_web_app.webapp2.identity[0].principal_id
  secret_permissions = [
    "Get", 
    "List",
    "Set"
  ]
}







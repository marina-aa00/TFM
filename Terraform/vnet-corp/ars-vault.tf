//Azure Recovery Services vault 

resource "azurerm_recovery_services_vault" "ars-vault" {
  name                = "ars-pro-main-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = true 
  storage_mode_type   = "LocallyRedundant" 
  identity {
    type = "SystemAssigned"
  }
  encryption {
    key_id                            = azurerm_key_vault_key.ars-key.id
    use_system_assigned_identity      = true
    infrastructure_encryption_enabled = false 
  }
  depends_on = [
    azurerm_key_vault_key.ars-key
  ]
}

//Virtual machines custom backup policy 

resource "azurerm_backup_policy_vm" "vm-backup-policy" {
  name                = "az-vm-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.ars-vault.name
  policy_type         = "V2" 
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "08:00"
  }
  instant_restore_retention_days = 2
  instant_restore_resource_group {
    prefix = "az-rg-ars-vault"
    suffix = "east-us"
  }
  retention_daily {
    count = 7
  }
  depends_on = [
    azurerm_recovery_services_vault.ars-vault
  ]
}
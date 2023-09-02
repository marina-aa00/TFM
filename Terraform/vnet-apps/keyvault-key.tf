//Keyvault key for Transparent Data Encryption (TDE) of SQL server 
resource "azurerm_key_vault_key" "sql-key" {
  name         = "sql-server-encryptionkey"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "unwrapKey",
    "wrapKey",
  ]
  expiration_date = "2023-09-30T20:00:00Z" //Key expiration date
  rotation_policy {
    automatic {
      time_before_expiry = "P30D" // Automatic Rotation of the key 30 days before it expires
    }

  }
}

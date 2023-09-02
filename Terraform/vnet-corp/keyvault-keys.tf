//Keys

//Key used for the encryption at rest of the ARS vault
resource "azurerm_key_vault_key" "ars-key" {
  name         = "ars-vault-encryptionkey"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  expiration_date =       "2023-09-30T20:00:00Z" //Key expiration date
  rotation_policy {
    automatic {
      time_before_expiry = "P30D" // Automatic Rotation of the key 30 days before it expires
    }
  }
}

//Key used for ADE of virtual desktop vm-pro-wvd-01
resource "azurerm_key_vault_key" "kv-ade-vm-vd-1" {
    name                            =       "virtualdesktop1-ade-kek"
    key_vault_id                    =       var.key_vault_id
    key_type                        =       "RSA"
    key_size                        =       4096
    key_opts                        =       ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
    expiration_date                 =       "2023-09-30T20:00:00Z" //Key expiration date
    rotation_policy {
    automatic {
      time_before_expiry = "P30D" // Automatic Rotation of the key 30 days before it expires
    }
  }
}

//Key used for ADE of virtual desktop vm-pro-wvd-02
resource "azurerm_key_vault_key" "kv-ade-vm-vd-2" {
    name                            =       "virtualdesktop2-ade-kek"
    key_vault_id                    =       var.key_vault_id
    key_type                        =       "RSA"
    key_size                        =       4096
    key_opts                        =       ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
    expiration_date                 =       "2023-09-30T20:00:00Z" //Key expiration date
    rotation_policy {
    automatic {
      time_before_expiry = "P30D" // Automatic Rotation of the key 30 days before it expires
    }
  }
}

//Key used for ADE of virtual desktop vm-pro-wvd-03
resource "azurerm_key_vault_key" "kv-ade-vm-vd-3" {
    name                            =       "virtualdesktop3-ade-kek"
    key_vault_id                    =       var.key_vault_id
    key_type                        =       "RSA"
    key_size                        =       4096
    key_opts                        =       ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
    expiration_date                 =       "2023-09-30T20:00:00Z" //Key expiration date
    rotation_policy {
    automatic {
      time_before_expiry = "P30D" // Automatic Rotation of the key 30 days before it expires
    }
  }
}

//Key used for ADE of main VM 
resource "azurerm_key_vault_key" "kv-ade-vm-main" {
    name                            =       "vm-main-ade-kek"
    key_vault_id                    =       var.key_vault_id
    key_type                        =       "RSA"
    key_size                        =       4096
    key_opts                        =       ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
    expiration_date                 =       "2023-09-30T20:00:00Z" //Key expiration date
    rotation_policy {
    automatic {
      time_before_expiry = "P30D" // Automatic Rotation of the key 30 days before it expires
    }
  }
}

//Key used for ADE of VM host for SQL Server on VM
resource "azurerm_key_vault_key" "kv-ade-vm-sql-server" {
    name                            =       "vm-sql-server-ade-kek"
    key_vault_id                    =       var.key_vault_id
    key_type                        =       "RSA"
    key_size                        =       4096
    key_opts                        =       ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey",]
    expiration_date                 =       "2023-09-30T20:00:00Z" //Key expiration date
    rotation_policy {
    automatic {
      time_before_expiry = "P30D" // Automatic Rotation of the key 30 days before it expires
    }
  }
}


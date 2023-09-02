//Keyvault secrets

//Local password for virtual desktop vm-pro-wvd-01
resource "azurerm_key_vault_secret" "keyvault_secret_vd_01" {
  name            = "secret-vd01"
  value           = element(var.windows_servers_local_passwords,0)
  key_vault_id    = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00" 
  content_type    = "Password" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}

//Local password for virtual desktop vm-pro-wvd-02
resource "azurerm_key_vault_secret" "keyvault_secret_vd_02" {
  name            = "secret-vd02"
  value           = element(var.windows_servers_local_passwords,1)
  key_vault_id    = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00" 
  content_type    = "Password" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}

//Local password for virtual desktop vm-pro-wvd-03
resource "azurerm_key_vault_secret" "keyvault_secret_vd_03" {
  name            = "secret-vd03"
  value           = element(var.windows_servers_local_passwords,2)
  key_vault_id    = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00" 
  content_type    = "Password" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}

//Local password for main VM
resource "azurerm_key_vault_secret" "keyvault_secret_vm-main" {
  name            = "secret-vm-main"
  value           = var.windows_mainvm_app_password
  key_vault_id    = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00" 
  content_type    = "Password" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}

//Local password for VM host for SQL server on VM
resource "azurerm_key_vault_secret" "keyvault_secret_vm-sql-server" {
  name            = "secret-vm-sql-server"
  value           = var.sql-server-vm-password
  key_vault_id    = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00" 
  content_type    = "Password" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}

//Local password for sysadmin of SQL Server on VM
resource "azurerm_key_vault_secret" "keyvault_secret_vm-sql-server-update" {
  name            = "secret-vm-sql-server-update"
  value           = var.sql-server-update-password
  key_vault_id    = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00" 
  content_type    = "Password" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}
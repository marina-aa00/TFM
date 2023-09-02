//Keyvault secrets

//Secret for apppro-payin-01 AD authentication
resource "azurerm_key_vault_secret" "keyvault_secret_appin" {
  name         = "secret-appin"
  value        = var.secret_app1 
  key_vault_id = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00" 
  content_type = "App AD authentication secret" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}

//Secret for apppro-payout-01 AD authentication
resource "azurerm_key_vault_secret" "keyvault_secret_appout" {
  name         = "secret-appout"
  value        = var.secret_app2
  key_vault_id = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00"
  content_type = "App AD authentication secret" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}

//Secret for connection string of app services to sql server
resource "azurerm_key_vault_secret" "keyvault_secret_connection_string" {
  name         = "connection-string"
  value        = var.connstr-sql-webapp
  key_vault_id = var.key_vault_id
  expiration_date = "2023-08-13T07:45:37+00:00"
  content_type = "SQL Connection String" //This field was added to enhance security after perfoming the static code analysis of the IaC templates
}
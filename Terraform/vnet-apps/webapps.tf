//App service plan
resource "azurerm_service_plan" "webapps_plan" { 
  name                = var.app_service_plan
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  os_type             = "Linux" 
  sku_name            = "P1v2"
}

//Webapp app-pro-payin-01 which manages incoming payments 
resource "azurerm_linux_web_app" "webapp1" {
  client_affinity_enabled   = true
  name                      = var.webapp1_name
  resource_group_name       = var.resource_group_name
  location                  = azurerm_service_plan.webapps_plan.location
  service_plan_id           = var.service-plan-id
  virtual_network_subnet_id = azurerm_subnet.appserv-sub.id
  https_only                = true

  identity {
    type = "SystemAssigned"
  }

  connection_string {
    name  = "AZURE_SQL_CONNECTIONSTRING" 
    type  = "SQLAzure"
    value = "@Microsoft.KeyVault(SecretUri=https://kv-pro-main-01.vault.azure.net/secrets/connection-string/)"  
  }
  site_config {
    minimum_tls_version = "1.2"
    always_on = false
    vnet_route_all_enabled = true
   
    //Access control ip restrictions
    ip_restriction { 
                  ip_address = "2.153.193.121/32"
                  action = "Allow"
                  headers = []
                  service_tag = null
                  priority = 1
                  virtual_network_subnet_id = null
                  name = "allowRegisteredClient"            
    }
    
    ftps_state = "FtpsOnly"
    http2_enabled = true
    application_stack {
    dotnet_version ="6.0"
  }
  }
  
  //Authentication with AAD for login
  auth_settings {
    enabled                       = true
    unauthenticated_client_action = "RedirectToLoginPage" 
    default_provider              = "AzureActiveDirectory"
    issuer                        = "https://sts.windows.net/${var.tenant_id}/v2.0"
    token_store_enabled           = true
    active_directory {
      client_id                   = var.client_id1
      allowed_audiences           = ["https://${var.webapp1_name}.azurewebsites.net"]
      client_secret               = azurerm_key_vault_secret.keyvault_secret_appin.value
    }
  } 
  depends_on = [
    azurerm_service_plan.webapps_plan,
    azurerm_subnet.appserv-sub,
  ]
}


//Webapp app-pro-payout-01 which manages outgoing payments
resource "azurerm_linux_web_app" "webapp2" {
  client_affinity_enabled   = true
  name                      = var.webapp2_name
  resource_group_name       = var.resource_group_name
  location                  = azurerm_service_plan.webapps_plan.location
  service_plan_id           = var.service-plan-id
  virtual_network_subnet_id = azurerm_subnet.appserv-sub.id
  https_only                = true
  identity {
    type = "SystemAssigned"
  }

  connection_string {
    name  = "AZURE_SQL_CONNECTIONSTRING"
    type  = "SQLAzure"
    value = "@Microsoft.KeyVault(SecretUri=https://kv-pro-main-01.vault.azure.net/secrets/connection-string/)"  
  }

  site_config {
    always_on = false
    vnet_route_all_enabled = true
    minimum_tls_version = "1.2"

    //Access control ip restrictions
    ip_restriction {
                  ip_address = "2.153.193.121/32"
                  action = "Allow"
                  headers = []
                  service_tag = null
                  priority = 1
                  virtual_network_subnet_id = null
                  name = "allowRegisteredClient"            
    }
    
    ftps_state = "FtpsOnly"
    http2_enabled = true
    application_stack {
    dotnet_version ="6.0"
  }
  }

  //Authentication with AAD for login
  auth_settings {
    enabled                       = true
    unauthenticated_client_action = "RedirectToLoginPage" 
    default_provider              = "AzureActiveDirectory"
    issuer                        = "https://sts.windows.net/${var.tenant_id}/v2.0"
    token_store_enabled           = true
    active_directory {
      client_id                   = var.client_id2
      allowed_audiences           = ["https://${var.webapp2_name}.azurewebsites.net"]
      client_secret               = azurerm_key_vault_secret.keyvault_secret_appout.value
      
    }
  } 
  depends_on = [
    azurerm_service_plan.webapps_plan,
    azurerm_subnet.appserv-sub,
  ]
}


//Binding of app-pro-payin01 with app URL
resource "azurerm_app_service_custom_hostname_binding" "cust-webapp1" {
  app_service_name    = var.webapp1_name
  hostname            = "${var.webapp1_name}.azurewebsites.net"
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_linux_web_app.webapp1,
  ]
}

//Binding of app-pro-payout01 with app URL
resource "azurerm_app_service_custom_hostname_binding" "cust-webapp2" {
  app_service_name    = var.webapp2_name
  hostname            = "${var.webapp2_name}.azurewebsites.net"
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_linux_web_app.webapp2,
  ]
}

//Monitoring of logs of app-pro-payin01 with log analytics workspace
resource "azurerm_monitor_diagnostic_setting" "diag-sett-app1" {
      name                       = "diag-sett-app1"
      target_resource_id         = azurerm_linux_web_app.webapp1.id
      log_analytics_workspace_id = var.log-analytics-wkspace-id
      dynamic "enabled_log" {
        iterator = entry
        for_each = var.loganalytics_categories
        content {
          category = entry.value

          retention_policy {
            enabled = false
          }
        }
      }
    
      metric {
        category = "AllMetrics"
    
        retention_policy {
          enabled = false
        }
      }
      lifecycle {
        ignore_changes = [log, metric]
      }
      depends_on = [
        azurerm_linux_web_app.webapp1
      ]
    }

    //Monitoring of logs of app-pro-payout-01 with logs analytics workspace
    resource "azurerm_monitor_diagnostic_setting" "diag-sett-app2" {
      name                       = "diag-sett-app2"
      target_resource_id         = azurerm_linux_web_app.webapp2.id
      log_analytics_workspace_id = var.log-analytics-wkspace-id

       dynamic "enabled_log" {
        iterator = entry
        for_each = var.loganalytics_categories
        content {
          category = entry.value

          retention_policy {
            enabled = false
          }
        }
      }

      metric {
        category = "AllMetrics"
    
        retention_policy {
          enabled = false
        }
      }
      lifecycle {
        ignore_changes = [log, metric]
      }
      depends_on = [
        azurerm_linux_web_app.webapp2
      ]
    }










///SQL server and SQL database security features

//Transparent data encryption (TDE) of SQL server
resource "azurerm_mssql_server_transparent_data_encryption" "sql-db-encryption" {
  server_id = var.sql-server-id
  key_vault_key_id = azurerm_key_vault_key.sql-key.id
  depends_on = [
    azurerm_key_vault_key.sql-key
  ]
}

//SQL server and database monitoring

resource "azurerm_monitor_diagnostic_setting" "diag-sett" {
  name                       = "marina-DS-SQL"
  target_resource_id         = var.sql-master-db-id
  log_analytics_workspace_id = var.log-analytics-wkspace-id
  

  enabled_log {
    category = "SQLSecurityAuditEvents"
    

    retention_policy {
      enabled = false
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
}





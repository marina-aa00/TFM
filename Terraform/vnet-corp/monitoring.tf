// Log Analytics Workspace for monitoring of corporate virtual network
resource "azurerm_log_analytics_workspace" "vnet-corp-wkspace" {
  name                      = "vnet-corp-loganalytics"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku                       = "PerGB2018"
  retention_in_days         = 365
  internet_ingestion_enabled= true
  internet_query_enabled    = false
}

//Log Analytics solution to allow the integration of the Log Analytics workspace with Azure Monitor for the VMs
resource "azurerm_log_analytics_solution" "vminsights" {
  solution_name         = "vm-insights"
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.vnet-corp-wkspace.id
  workspace_name        = azurerm_log_analytics_workspace.vnet-corp-wkspace.name
  plan {
    publisher = "Microsoft"
    product   = "VMInsights"
  }
  depends_on = [
    azurerm_log_analytics_workspace.vnet-corp-wkspace,
  ]
}

//Monitoring of FW logs with log analytics workspace 
resource "azurerm_monitor_diagnostic_setting" "fw-diag" {
  name                       = "fw-diag-logs"
  target_resource_id         = azurerm_firewall.fw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.vnet-corp-wkspace.id

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
azurerm_firewall.fw
]
}
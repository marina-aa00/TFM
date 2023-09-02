//RBAC configuration

//Employee

//Role assignment for employee to manage and perform AAD login on the virtual machines in vnet corp 
resource "azurerm_role_assignment" "virtual_machine_user_login" {
  scope                = var.resource_group_id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = var.principal_user_id
}

//Role assignment for employee to manage VM backups to the ARS vault 
resource "azurerm_role_assignment" "backup_operator" {
  scope                = var.resource_group_id
  role_definition_name = "Backup Operator"
  principal_id         = var.principal_user_id
}

//Role assignment for employee to view resources in the Azure portal
resource "azurerm_role_assignment" "reader" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = var.principal_user_id
}

//Role assignment for employee to view monitoring data and diagnostics 
resource "azurerm_role_assignment" "log_analytics_reader" {
  scope                = var.resource_group_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = var.principal_user_id
}


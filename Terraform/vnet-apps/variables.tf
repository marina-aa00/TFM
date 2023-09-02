variable "resource_group_location" {
  default     = "eastus"
  type        = string
  description = "Location of the resource group"
}

variable "resource_group_name" {
  default     = "marina"
  type        = string
  description = "Name of resource group"
}

variable "app_service_plan" {
  default     = "webapps-app-service-plan"
  type        = string
  description = "Name of the app-service plan"
}

variable "webapp1_name" {
    default     = "apppro-payin-01"
    type        = string
    description = "Name of the app for inbound payments"
}

variable "webapp2_name" {
    default     = "apppro-payout-01"
    type        = string
    description = "Name of the app for outbound payments"
}

variable "appgw_name" {
    default     = "appgw-pro-api-payments-01"
    type        = string
    description = "Name of the app gateway"
}

variable "pip_name" {
    default     = "public-ip-app-gw"
    type        = string
    description = "Public ip address for the app gw"
}

variable "appgw-subnetwork" {
  default     = "appgw-subnetwork"
  type        = string
  description = "Subnetwork for the app gw"
}

variable "appserv-subnetwork" {
  default     = "appserv-subnetwork"
  type        = string
  description = "Subnetwork for the app services"
}

variable "app-gw-name" {
  default     = "appgw-pro-api-payments-01"
  type        = string
  description = "Name of app gw"
}

variable "backend-address-pool-name" {
  default     = "webapps-pool1"
  type        = string
  description = "Name of the address pool for the webapps"
}

variable "backend-address-pool-name2" {
  default     = "webapps-pool2"
  type        = string
  description = "Name of the address pool for the webapps"
}

variable "appgw-http-settings" {
  default     = "appgw-http-settings"
  type        = string
  description = "Name of the http settings of the app gw"
}

variable "appgw-http-settings2" {
  default     = "appgw-http-settings2"
  type        = string
  description = "Name of the http settings of the app gw"
}

variable "listener-appgw-name" {
  default     = "appgw-listener"
  type        = string
  description = "Name of the listener of the app gw"
}

variable "listener-appgw-name2" {
  default     = "appgw-listener2"
  type        = string
  description = "Name of the listener of the app gw"
}

variable "appgw-routing-rule" {
  default     = "appgw-routing-rule"
  type        = string
  description = "Name of the routing rule of the app gw"
}

variable "appgw-routing-rule2" {
  default     = "appgw-routing-rule2"
  type        = string
  description = "Name of the routing rule of the app gw"
}

variable "loganalytics_categories" {
  description = "Categories of logs to send to Log analytics workspace"
  type        = list(string)
  default     = ["AppServiceHTTPLogs", "AppServiceConsoleLogs","AppServiceAppLogs","AppServiceAuditLogs","AppServiceIPSecAuditLogs","AppServicePlatformLogs"]
}

//Sensitive fields - avoid harcoded values

variable "key_vault_id" {
  description = "Id of the keyvault"
  type = string
}

variable "tenant_id" { 
  description = "ID of the tenant"
  type = string
}

variable "principal_user_id" {
  description = "Id of user in Azure AD"
  type = string
}

variable "client_id1" { 
  description = "ID of the app-pro-payin01"
  type = string
}

variable "client_id2" { 
  description = "ID of the app-pro-payout01"
  type = string
}

variable "secret_app1" {
  description = "Secret for the auth of webapp app-pro-payin01"
  type = string
}

variable "secret_app2" {
  description = "Secret for the auth of webapp app-pro-payout01"
  type = string
}

variable "connstr-sql-webapp" {
  description = "Value of the connection string between the webapps and the SQL server"
  type = string
}

variable "sql-server-id" {
  description = "Id of the sql server"
  type = string
}

variable "sql-master-db-id" {
  description = "Id of the sql master db"
  type = string
}

variable "log-analytics-wkspace-id" {
  description = "Id of the loganalytics workspace"
  type = string
}


variable "service-plan-id" {
  description = "Id of the webapps service plan"
  type = string
}



variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = "marina"
}

variable "location" {
  description = "Location of the resource group"
  type        = string
  default     = "eastus"
}

variable "bastion_name" {
  description = "String to name the bastion resources."
  type        = string
  default     = "pro-bastion-01"
}

variable "windows_servers_names" {
  description = "Names for Windows virtual desktops."
  type        = list(string)
  default     = ["vm-pro-wvd-01","vm-pro-wvd-02","vm-pro-wvd-03"]
}

variable "windows_servers_nic_names"{
  description = "Windows servers network interfaces names"
  type        = list(string)
  default     = ["vm-pro-wvd-01-nic","vm-pro-wvd-02-nic","vm-pro-wvd-03-nic"]
}

variable "windows_servers_os_disk_names"{
  description = "Windows servers os disk names"
  type        = list(string)
  default     = ["vm-pro-wvd-01-os","vm-pro-wvd-02-os","vm-pro-wvd-03-os"]
}


variable "size" {
  description = "Azure virtual machine size."
  type = string
  default     = "Standard_D2s_v3"
}

variable "virtual_network_name" {
  description = "Name for the corporate virtual network."
  type        = string
  default     = "vnet-main-pro"
}

variable "vnet_address_space" {
  description = "Virtual network address space."
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_name_bastion" {
  description = "Name of the subnet for the Azure bastion."
  type        = string
  default     = "AzureBastionSubnet"
}

variable "subnet_name_vdesktop" {
  description = "Name of the subnet for the virtual desktops."
  type        = string
  default     = "subnet_virtual_desktops"
}

variable "subnet_name_vm_main" {
  description = "Name of the subnet for the main virtual machine."
  type        = string
  default     = "subnet_main_vm"
}

variable "subnet_name_vm_sql_server" {
  description = "Name of the subnet for the sql server."
  type        = string
  default     = "subnet_sql_server"
}


variable "subnet_name_fw" {
  description = "Name of the subnet for the Azure FW."
  type        = string
  default     = "AzureFirewallSubnet"
}

variable "subnet_bastion_address_space" {
  description = "Subnet address space for the bastion host."
  type        = string
  default     = "10.1.0.0/26"
}

variable "subnet_virtual_desktops_address_space" {
  description = "Subnet address space for the virtual desktops."
  type        = string
  default     = "10.1.1.0/24"
}

variable "subnet_main_vm_address_space" {
  description = "Subnet address space for the main vm."
  type        = string
  default     = "10.1.2.0/24"
}

variable "subnet_sql_server_address_space" {
  description = "Subnet address space for the sql server."
  type        = string
  default     = "10.1.3.0/24"
}

variable "subnet_fw_address_space" {
  description = "Subnet address space for the FW subnet."
  type        = string
  default     = "10.1.5.0/24"
}

variable "scale_units" {
  description = "Number of hosts supported by the Bastion service."
  type        = number
  default     = 3
}

variable "loganalytics_categories" {
  description = "Categories of logs to send to Log analytics workspace"
  type = list(string)
  default = ["AzureFirewallApplicationRule","AzureFirewallNetworkRule","AZFWNetworkRule","AZFWApplicationRule","AZFWThreatIntel"]
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

variable "backup_mgmt_service_id" { 
  description = "ID of the Backup Management Service"
  type = string
}

variable "parent_resource_id" { 
  description = "ID of parent resource for enabling Just in time access in main VM"
  type = string
}

variable "vnet-apps-id" {
  description = "Resource id of vnet that hosts the apps"
  type = string
}

variable "windows_servers_local_usernames" {
  description = "VM local account usernames."
  type        = list(string)
}

variable "windows_servers_local_passwords" {
  description = "Passwords for Windows servers."
  type        = list(string)
  sensitive   = true
}

variable "windows_mainvm_app_username"{
  description = "VM main admin account username."
  type        = string
}

variable "windows_mainvm_app_password" {
  description = "Password for main VM admin user account."
  type        = string
  sensitive   = true
}

variable "sql-server-vm-username" {
  description = "Username for VM host of SQL server"
  type        = string
}

variable "sql-server-vm-password" {
  description = "Password for VM host of SQL server"
  type        = string
}

variable "sql-server-update-username" {
  description = "Username for update of SQL server"
  type        = string
}

variable "sql-server-update-password" {
  description = "Password for update of SQL server"
  type        = string
}





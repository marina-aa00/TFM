//SQL Server in VM 

//NIC of VM host for SQL Server (private ip address only)

resource "azurerm_network_interface" "nic-vm-sql-server" {
  name                = "vm-sql-server-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "vm-sql-server-nic-ip-conf"
    subnet_id                     = azurerm_subnet.sql-server.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_subnet.sql-server
  ]
}

//Windows VM host for SQL Server 
resource "azurerm_windows_virtual_machine" "vm-sql-server" {
  name                      = "vm-sql-pro-app2"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  network_interface_ids     = [azurerm_network_interface.nic-vm-sql-server.id]
  size                      = var.size
  admin_username            = var.sql-server-vm-username
  admin_password            = var.sql-server-vm-password
  provision_vm_agent        = true
  
  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "sqldev-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "vm-sql-server-osdisk"
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }
   depends_on = [
    azurerm_network_interface.nic-vm-sql-server
  ]
}

//Extensions

//Extension to allow AAD login
resource "azurerm_virtual_machine_extension" "AADLoginForWindows-vm-sql-server" {
  name                       = "AADLoginForWindows-vm-sql-server"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-sql-server.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm-sql-server
  ]
}

//Extension to activate Antimalware on VM host for SQL server

resource "azurerm_virtual_machine_extension" "IaaSAntimalware-vm-sql-server" {
  name                       = "IaaSAntimalware"
  virtual_machine_id         = "${azurerm_windows_virtual_machine.vm-sql-server.id}"
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3" 
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
        {  
          "AntimalwareEnabled": true,
          "RealtimeProtectionEnabled": "true",
          "ScheduledScanSettings": {
            "isEnabled": "true",
            "day": "1",
            "time": "120",
            "scanType": "Quick"
          },
          "Exclusions": {
            "Extensions": "",
            "Paths": "",
            "Processes": ""
          }
        }
  SETTINGS
  depends_on = [
    azurerm_windows_virtual_machine.vm-sql-server
  ]

}

//Extension for Azure Disk Encryption (ADE) of Operating system disk (encryption of data at rest)

resource "azurerm_virtual_machine_extension" "ade-vm-sql-server" {
    name                              =     "AzureDiskEncryption"
    virtual_machine_id                =     azurerm_windows_virtual_machine.vm-sql-server.id
    publisher                         =     "Microsoft.Azure.Security"
    type                              =     "AzureDiskEncryption"
    type_handler_version              =     "2.2"
    auto_upgrade_minor_version        =     true

    settings = <<SETTINGS
    {
        "EncryptionOperation"         :     "EnableEncryption",
        "KeyVaultURL"                 :     "https://kv-pro-main-01.vault.azure.net",
        "KeyVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionKeyURL"         :     "https://kv-pro-main-01.vault.azure.net/keys/vm-sql-server-ade-kek/${azurerm_key_vault_key.kv-ade-vm-sql-server.version}",
        "KekVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionAlgorithm"      :     "RSA-OAEP",
        "VolumeType"                  :     "All"
    }
    SETTINGS

    depends_on                        =     [azurerm_windows_virtual_machine.vm-sql-server]
}

//Extensions needed to enable Azure Monitor agent on SQL server VM

// The dependency agent extension is needed for other extensions to deploy successfully
resource "azurerm_virtual_machine_extension" "daa-agent-sql-server" {
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-sql-server.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm-sql-server
  ]
}

// Logging and monitoring extensions (Azure Monitor Agent and Microsoft Monitoring agent)
resource "azurerm_virtual_machine_extension" "monitor-agent-sql-server" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-sql-server.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       =  "1.5"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  depends_on                 = [  azurerm_virtual_machine_extension.daa-agent-sql-server, azurerm_windows_virtual_machine.vm-sql-server ]

}

resource "azurerm_virtual_machine_extension" "msmonitor-agent-sql-server" {
  name                  = "MicrosoftMonitoringAgent"  
  virtual_machine_id    = azurerm_windows_virtual_machine.vm-sql-server.id
  publisher             = "Microsoft.EnterpriseCloud.Monitoring"
  type                  = "MicrosoftMonitoringAgent"
  type_handler_version  =  "1.0"
  depends_on            = [  azurerm_virtual_machine_extension.daa-agent-sql-server, azurerm_windows_virtual_machine.vm-sql-server  ]
  settings = <<SETTINGS
    {
        "workspaceId": "${azurerm_log_analytics_workspace.vnet-corp-wkspace.workspace_id}",
        "azureResourceId": "${azurerm_windows_virtual_machine.vm-sql-server.id}",
        "stopOnMultipleConnections": "false"
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.vnet-corp-wkspace.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

//Vulnerability assesments 

// Vulnerability assesment (Qualys) for sql server on VM
resource "azurerm_security_center_server_vulnerability_assessment_virtual_machine" "vuln-ass-vm-sql-server" {
  virtual_machine_id = azurerm_windows_virtual_machine.vm-sql-server.id
  depends_on         = [  azurerm_virtual_machine_extension.daa-agent-sql-server, azurerm_windows_virtual_machine.vm-sql-server ]
}

// SQL Server on the Windows VM host
resource "azurerm_mssql_virtual_machine" "mssql" {
  virtual_machine_id               = azurerm_windows_virtual_machine.vm-sql-server.id
  sql_license_type                 = "PAYG"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = var.sql-server-update-username
  sql_connectivity_update_username = var.sql-server-update-password
  depends_on = [
    azurerm_windows_virtual_machine.vm-sql-server
  ]
}

//Backup 

//Azure Backup for sql server virtual machine
resource "azurerm_backup_protected_vm" "vm-backup-sql-server-vm" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.ars-vault.name
  source_vm_id        = azurerm_windows_virtual_machine.vm-sql-server.id 
  backup_policy_id    = azurerm_backup_policy_vm.vm-backup-policy.id
  depends_on = [
    azurerm_recovery_services_vault.ars-vault,
    azurerm_windows_virtual_machine.vm-sql-server,
    azurerm_backup_policy_vm.vm-backup-policy
  ]
}
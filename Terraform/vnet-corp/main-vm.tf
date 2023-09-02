//Main Windows Virtual Machine (vm-pro-app-01) which hosts the server that contains the application that keeps track of the payments

//Network interface for main Virtual machine (private ip address only)
resource "azurerm_network_interface" "vm-main-nic" {
  name                = "vm-pro-app-01-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-main.id 
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_subnet.vm-main
  ]
}

//Windows main Virtual machine
resource "azurerm_windows_virtual_machine" "vm-main" { 
  name                = "vm-pro-app-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  

  admin_username      = var.windows_mainvm_app_username
  admin_password      = var.windows_mainvm_app_password
  size                = var.size

  network_interface_ids = [
    azurerm_network_interface.vm-main-nic.id,
  ]

  tags = {
    Name = "VM-main-app"
  }


  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  os_disk {
    name                 = "vm-pro-app-01-os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" 
    disk_size_gb         =  128
  }

  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_network_interface.vm-main-nic
  ]
}

//Extensions

//Extension to allow AAD login from virtual desktops

resource "azurerm_virtual_machine_extension" "AADLoginForWindows-vm-main" {
  name                       = "AADLoginForWindows-vm-main"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-main.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm-main
  ]
}

//Extension to activate Antimalware on main VM

resource "azurerm_virtual_machine_extension" "IaaSAntimalware-vm-main" {
  name                       = "IaaSAntimalware"
  virtual_machine_id         = "${azurerm_windows_virtual_machine.vm-main.id}"
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
    azurerm_windows_virtual_machine.vm-main
  ]
}

//Extension for Azure Disk Encryption (ADE) of Operating system disk (encryption of data at rest)

resource "azurerm_virtual_machine_extension" "ade-main" {
    name                              =     "AzureDiskEncryption"
    virtual_machine_id                =     azurerm_windows_virtual_machine.vm-main.id
    publisher                         =     "Microsoft.Azure.Security"
    type                              =     "AzureDiskEncryption"
    type_handler_version              =     "2.2"
    auto_upgrade_minor_version        =     true

    settings = <<SETTINGS
    {
        "EncryptionOperation"         :     "EnableEncryption",
        "KeyVaultURL"                 :     "https://kv-pro-main-01.vault.azure.net",
        "KeyVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionKeyURL"         :     "https://kv-pro-main-01.vault.azure.net/keys/vm-main-ade-kek/${azurerm_key_vault_key.kv-ade-vm-main.version}",
        "KekVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionAlgorithm"      :     "RSA-OAEP",
        "VolumeType"                  :     "All"
    }
    SETTINGS

    depends_on                        =     [azurerm_windows_virtual_machine.vm-main]
}

//Extensions needed to enable Azure Monitor agent on main VM

// The dependency agent extension is needed for other extensions to deploy successfully
resource "azurerm_virtual_machine_extension" "daa-agent-main" {
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-main.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm-main
  ]
}

// Logging and monitoring extensions (Azure Monitor agent and Microsoft Monitoring agent)
resource "azurerm_virtual_machine_extension" "monitor-agent-main" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-main.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       =  "1.5"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  depends_on                 = [  azurerm_virtual_machine_extension.daa-agent-main, azurerm_windows_virtual_machine.vm-main  ]
}

resource "azurerm_virtual_machine_extension" "msmonitor-agent-main" {
  name                  = "MicrosoftMonitoringAgent"  
  virtual_machine_id    = azurerm_windows_virtual_machine.vm-main.id
  publisher             = "Microsoft.EnterpriseCloud.Monitoring"
  type                  = "MicrosoftMonitoringAgent"
  type_handler_version  =  "1.0"
  depends_on            = [  azurerm_virtual_machine_extension.daa-agent-main, azurerm_windows_virtual_machine.vm-main  ]
  settings = <<SETTINGS
    {
        "workspaceId": "${azurerm_log_analytics_workspace.vnet-corp-wkspace.workspace_id}",
        "azureResourceId": "${azurerm_windows_virtual_machine.vm-main.id}",
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

// Vulnerability assesment (Qualys) for main VM
resource "azurerm_security_center_server_vulnerability_assessment_virtual_machine" "vuln-ass-main" {
  virtual_machine_id = azurerm_windows_virtual_machine.vm-main.id
  depends_on         = [  azurerm_virtual_machine_extension.daa-agent-main, azurerm_windows_virtual_machine.vm-main  ]
}

//JIT

//Just in time access for VM main (3 hours of access allowed before having to request for access again)
resource "azapi_resource" "jit-vm-main" {
  type = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
  name = "vm-main-jit-policy"
  parent_id = var.parent_resource_id
  schema_validation_enabled = false 
  body = jsonencode({
    properties = {
      virtualMachines = [
        {
          id = "${azurerm_windows_virtual_machine.vm-main.id}"
          ports = [
             {
              maxRequestAccessDuration   = "PT3H"
              number                     = 3389
              protocol                   = "TCP" 
              allowedSourceAddressPrefix = "${var.subnet_virtual_desktops_address_space}" 
            
            }
          ]
        }
      ]
    }
    kind = "Basic"
  })
}

//Backup

//Azure Backup for main virtual machine
resource "azurerm_backup_protected_vm" "vm-backup-main" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.ars-vault.name
  source_vm_id        = azurerm_windows_virtual_machine.vm-main.id 
  backup_policy_id    = azurerm_backup_policy_vm.vm-backup-policy.id
  depends_on = [
    azurerm_recovery_services_vault.ars-vault,
    azurerm_windows_virtual_machine.vm-main,
    azurerm_backup_policy_vm.vm-backup-policy
  ]
}
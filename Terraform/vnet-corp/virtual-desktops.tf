
// Virtual Machines (Virtual Desktops)


//Network interfaces for the virtual desktops (private ip address only)
resource "azurerm_network_interface" "vm-nic" {
  count               = 3
  name                = var.windows_servers_nic_names[count.index]
  resource_group_name = var.resource_group_name
  location            = var.location
  

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vms-virtualdesktop.id 
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.vms-virtualdesktop,
  ]
}

//Windows virtual machines used for the virtual desktops
resource "azurerm_windows_virtual_machine" "vm" { 
  count               = 3
  name                = var.windows_servers_names[count.index]
  resource_group_name = var.resource_group_name
  location            = var.location
  

  admin_username = var.windows_servers_local_usernames[count.index]
  admin_password = var.windows_servers_local_passwords[count.index]
  size           = var.size

  network_interface_ids = [
    azurerm_network_interface.vm-nic.*.id[count.index],
  ]

  tags = {
    Name = "VM-Virtual desktop-${count.index + 1}"
  }


  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  os_disk {
    name                 = var.windows_servers_os_disk_names[count.index]
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" 
     disk_size_gb        =  128
  }

  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_network_interface.vm-nic,
  ]
}


//Extensions 

//Extension for virtual desktops to allow Azure Active Directory login 

resource "azurerm_virtual_machine_extension" "AADLoginForWindows-vdesktops" {
  count                      = 3
  name                       = "AADLoginForWindows-wvd-0${count.index + 1}"
  virtual_machine_id         = "${element(azurerm_windows_virtual_machine.vm.*.id, count.index)}" 
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm,
  ]
}

//Extension to activate Antimalware on virtual desktops

resource "azurerm_virtual_machine_extension" "IaaSAntimalware-vdesktops" {
  count                      = 3
  name                       = "IaaSAntimalware"
  virtual_machine_id         = "${element(azurerm_windows_virtual_machine.vm.*.id, count.index)}"
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
    azurerm_windows_virtual_machine.vm,
  ]

}

//Extension for Azure Disk Encryption (ADE) of Operating system disks (encryption of data at rest)

//ADE for virtual desktop vm-pro-wvd-01
resource "azurerm_virtual_machine_extension" "ade-vd-1" {
    name                              =     "AzureDiskEncryption"
    virtual_machine_id                =     "${element(azurerm_windows_virtual_machine.vm.*.id, 0)}"
    publisher                         =     "Microsoft.Azure.Security"
    type                              =     "AzureDiskEncryption"
    type_handler_version              =     "2.2"
    auto_upgrade_minor_version        =     true

    settings = <<SETTINGS
    {
        "EncryptionOperation"         :     "EnableEncryption",
        "KeyVaultURL"                 :     "https://kv-pro-main-01.vault.azure.net",
        "KeyVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionKeyURL"         :     "https://kv-pro-main-01.vault.azure.net/keys/virtualdesktop1-ade-kek/${azurerm_key_vault_key.kv-ade-vm-vd-1.version}",
        "KekVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionAlgorithm"      :     "RSA-OAEP",
        "VolumeType"                  :     "All"
    }
    SETTINGS

    depends_on                        =     [azurerm_windows_virtual_machine.vm[0]]
}

//ADE for virtual desktop vm-pro-wvd-02
resource "azurerm_virtual_machine_extension" "ade-vd-2" {
    name                              =     "AzureDiskEncryption"
    virtual_machine_id                =     "${element(azurerm_windows_virtual_machine.vm.*.id, 1)}"
    publisher                         =     "Microsoft.Azure.Security"
    type                              =     "AzureDiskEncryption"
    type_handler_version              =     "2.2"
    auto_upgrade_minor_version        =     true

    settings = <<SETTINGS
    {
        "EncryptionOperation"         :     "EnableEncryption",
        "KeyVaultURL"                 :     "https://kv-pro-main-01.vault.azure.net",
        "KeyVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionKeyURL"         :     "https://kv-pro-main-01.vault.azure.net/keys/virtualdesktop2-ade-kek/${azurerm_key_vault_key.kv-ade-vm-vd-2.version}",
        "KekVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionAlgorithm"      :     "RSA-OAEP",
        "VolumeType"                  :     "All"
    }
    SETTINGS

    depends_on                        =     [azurerm_windows_virtual_machine.vm[1]]
}

//ADE for virtual desktop vm-pro-wvd-03
resource "azurerm_virtual_machine_extension" "ade-vd-3" {
    name                              =     "AzureDiskEncryption"
    virtual_machine_id                =     "${element(azurerm_windows_virtual_machine.vm.*.id, 2)}"
    publisher                         =     "Microsoft.Azure.Security"
    type                              =     "AzureDiskEncryption"
    type_handler_version              =     "2.2"
    auto_upgrade_minor_version        =     true

    settings = <<SETTINGS
    {
        "EncryptionOperation"         :     "EnableEncryption",
        "KeyVaultURL"                 :     "https://kv-pro-main-01.vault.azure.net",
        "KeyVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionKeyURL"         :     "https://kv-pro-main-01.vault.azure.net/keys/virtualdesktop3-ade-kek/${azurerm_key_vault_key.kv-ade-vm-vd-3.version}",
        "KekVaultResourceId"          :     "${var.key_vault_id}",
        "KeyEncryptionAlgorithm"      :     "RSA-OAEP",
        "VolumeType"                  :     "All"
    }
    SETTINGS

    depends_on                        =     [azurerm_windows_virtual_machine.vm[2]]
}

//Extensions needed to enable Azure Monitor agent on VMs

// The dependency agent extension is needed for other extensions to deploy successfully
resource "azurerm_virtual_machine_extension" "daa-agent" {
  count                      = 3
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = "${element(azurerm_windows_virtual_machine.vm.*.id, count.index)}"
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm,
  ]
}

// Logging and monitoring extensions (Azure Monitor Agent and Microsoft Monitoring agent )
resource "azurerm_virtual_machine_extension" "monitor-agent" {
  count                      = 3
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = "${element(azurerm_windows_virtual_machine.vm.*.id, count.index)}"
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       =  "1.5"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_windows_virtual_machine.vm,
    azurerm_virtual_machine_extension.daa-agent
  ]
}

resource "azurerm_virtual_machine_extension" "msmonitor-agent" {
  count                 = 3
  name                  = "MicrosoftMonitoringAgent"  
  virtual_machine_id    = "${element(azurerm_windows_virtual_machine.vm.*.id, count.index)}"
  publisher             = "Microsoft.EnterpriseCloud.Monitoring"
  type                  = "MicrosoftMonitoringAgent"
  type_handler_version  =  "1.0"
  depends_on            = [  azurerm_virtual_machine_extension.daa-agent, azurerm_windows_virtual_machine.vm  ]
  settings = <<SETTINGS
    {
        "workspaceId": "${azurerm_log_analytics_workspace.vnet-corp-wkspace.workspace_id }",
        "azureResourceId": "${element(azurerm_windows_virtual_machine.vm.*.id, count.index)}",
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

// Vulnerability assesment (Qualys) for virtual desktops
resource "azurerm_security_center_server_vulnerability_assessment_virtual_machine" "vuln-ass-vd" {
  count              = 3
  virtual_machine_id = "${element(azurerm_windows_virtual_machine.vm.*.id, count.index)}"
  depends_on = [
    azurerm_windows_virtual_machine.vm,
    azurerm_virtual_machine_extension.daa-agent
  ]
}

//Backup

//Azure Backup for virtual desktops
resource "azurerm_backup_protected_vm" "vm-backup-vd" {
  count               = 3
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.ars-vault.name
  source_vm_id        = "${element(azurerm_windows_virtual_machine.vm.*.id, count.index)}"
  backup_policy_id    = azurerm_backup_policy_vm.vm-backup-policy.id
  depends_on = [
    azurerm_recovery_services_vault.ars-vault,
    azurerm_windows_virtual_machine.vm,
    azurerm_backup_policy_vm.vm-backup-policy
  ]
}
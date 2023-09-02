//VNET and subnetworks 

//DdoS protection plan for corporate network
resource "azurerm_network_ddos_protection_plan" "ddos-protect-plan" {
  name                = "vnet-corp-ddos-protection"
  location            = var.location
  resource_group_name = var.resource_group_name
}

//Corporate network
resource "azurerm_virtual_network" "vnet-corp" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.ddos-protect-plan.id
    enable = true
  }
  depends_on = [
    azurerm_network_ddos_protection_plan.ddos-protect-plan
  ]
}


//Subnetwork where the virtual desktops are located
resource "azurerm_subnet" "vms-virtualdesktop" {
  name                 = var.subnet_name_vdesktop
  address_prefixes     = [var.subnet_virtual_desktops_address_space]
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
  service_endpoints    = ["Microsoft.KeyVault"] 
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}

//Subnetwork where the Azure bastion is located
resource "azurerm_subnet" "bastion" {
  name                 = var.subnet_name_bastion
  address_prefixes     = [var.subnet_bastion_address_space]
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}

//Subnetwork where the main VM (vm-pro-app-01) is located
resource "azurerm_subnet" "vm-main" {
  name                 = var.subnet_name_vm_main
  address_prefixes     = [var.subnet_main_vm_address_space]
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
  service_endpoints    = ["Microsoft.KeyVault"] 
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}

//Subnetwork where the SQL Server on VM is located
resource "azurerm_subnet" "sql-server" {
  name                 = var.subnet_name_vm_sql_server
  address_prefixes     = [var.subnet_sql_server_address_space]
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
  service_endpoints    = ["Microsoft.KeyVault"] 
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}


//FW subnet
resource "azurerm_subnet" "fw-subnet" {
  name                 = var.subnet_name_fw
  address_prefixes     = [var.subnet_fw_address_space]
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}

//Network security groups 

//NSG associated with the bastion subnetwork
resource "azurerm_network_security_group" "bastion" {
  name                = "AzureBastionSubnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowRdpOutbound"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = var.subnet_virtual_desktops_address_space
    destination_port_range    = "3389"
  }

}

//NSG associated with the virtual desktops subnetwork
resource "azurerm_network_security_group" "vms-virtualdesktops" {
  name                = "${var.subnet_name_vdesktop}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowRdpFromBastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.subnet_bastion_address_space 
    source_port_range          = "*"
    destination_address_prefix = var.subnet_virtual_desktops_address_space
    destination_port_range     = "3389"
  }
  security_rule {
    name                       = "AllowRdpToMainVM"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.subnet_virtual_desktops_address_space
    source_port_range          = "*"
    destination_address_prefix = var.subnet_main_vm_address_space
    destination_port_range    = "3389"
  }
}

//NSG associated with the main VM subnetwork

resource "azurerm_network_security_group" "vms-main" {
  name                = "${var.subnet_name_vm_main}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

   security_rule {
    name                       = "AllowRdpFromVDs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.subnet_virtual_desktops_address_space
    source_port_range          = "*"
    destination_address_prefix = var.subnet_main_vm_address_space
    destination_port_range     = "3389"
  }
  security_rule {
    name                       = "AllowRdpToSQLVM"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.subnet_main_vm_address_space
    source_port_range          = "*"
    destination_address_prefix = var.subnet_sql_server_address_space
    destination_port_range    = "3389"
  }
  security_rule {
    name                       = "AllowAzureFunction"
    priority                   = 102
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = var.subnet_main_vm_address_space
    source_port_range          = "*"
    destination_address_prefix = "10.0.2.0/24"
    destination_port_range     = "*"
  }
  security_rule {
    name                       = "AllowSQLServer"
    priority                   = 103
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = var.subnet_main_vm_address_space
    source_port_range          = "*"
    destination_address_prefix = "10.0.3.0/24"
    destination_port_range     = "*"
  }
}

//NSG associated with the SQL server VM subnetwork
resource "azurerm_network_security_group" "sql-server" {
  name                = "${var.subnet_name_vm_sql_server}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowRDPFromMainVM"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.subnet_main_vm_address_space
    source_port_range          = "*"
    destination_address_prefix = var.subnet_sql_server_address_space
    destination_port_range     = "3389"
  }


  security_rule {
    name                       = "AllowSQLVMFromMainVM"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.subnet_main_vm_address_space
    source_port_range          = "*"
    destination_address_prefix = var.subnet_sql_server_address_space
    destination_port_range     = "1433"
  }
  security_rule {
    name                       = "AllowSQLServer"
    priority                   = 102
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = var.subnet_sql_server_address_space
    source_port_range          = "*"
    destination_address_prefix = "10.0.3.0/24"
    destination_port_range     = "*"
  }
}

//Association of the bastion NSG with the subnetwork
resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
  depends_on = [
    azurerm_subnet.bastion,
    azurerm_network_security_group.bastion
  ]
}

//Association of the virtual desktops NSG with the subnetwork 
resource "azurerm_subnet_network_security_group_association" "vms-vd" {
  subnet_id                 = azurerm_subnet.vms-virtualdesktop.id
  network_security_group_id = azurerm_network_security_group.vms-virtualdesktops.id
  depends_on = [
    azurerm_subnet.vms-virtualdesktop,
    azurerm_network_security_group.vms-virtualdesktops
  ]
}

//Association of the main VM NSG with the subnetwork
resource "azurerm_subnet_network_security_group_association" "vms-main" {
  subnet_id                 = azurerm_subnet.vm-main.id
  network_security_group_id = azurerm_network_security_group.vms-main.id
  depends_on = [
    azurerm_subnet.vm-main,
    azurerm_network_security_group.vms-main
  ]
}

//Association of the SQL server VM NSG with the subnetwork
resource "azurerm_subnet_network_security_group_association" "sql-server" {
  subnet_id                 = azurerm_subnet.sql-server.id
  network_security_group_id = azurerm_network_security_group.sql-server.id
  depends_on = [
    azurerm_subnet.sql-server,
    azurerm_network_security_group.sql-server
  ]
}

//FW 

//Public ip address of the firewall
resource "azurerm_public_ip" "fw-public-ip" {
  name                = "fw-publicIP"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

//FW resource
resource "azurerm_firewall" "fw" {
  name                = "fw-outbound"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = "Standard" 
  sku_name            = "AZFW_VNet"
  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = azurerm_subnet.fw-subnet.id
    public_ip_address_id = azurerm_public_ip.fw-public-ip.id
  }
  threat_intel_mode = "Alert"
}

//Route table
resource "azurerm_route_table" "fw-route-table" {
  name                          = "fw-route-table"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true 

  route {
    name           = "route-outbound-connectivity"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "Production"
  }
}

//Associate route table with virtual desktops subnet
resource "azurerm_subnet_route_table_association" "route-table-vd-subnet" {
  subnet_id      = azurerm_subnet.vms-virtualdesktop.id
  route_table_id = azurerm_route_table.fw-route-table.id
}


//FW Network Rule collection
resource "azurerm_firewall_network_rule_collection" "network-rule-collection" {
  name                    = "fw-network-rules"
  azure_firewall_name     = azurerm_firewall.fw.name
  resource_group_name     = var.resource_group_name
  priority                = 100
  action                  = "Allow"
  rule {
    name                  = "network-rule-web-https"
    source_addresses      = ["10.1.1.0/24"] //Allow Internet connection originating from virtual desktops 
    destination_addresses = ["*"]
    destination_ports     = ["443"]
    protocols             = ["TCP"] 
  }
}

//FW Application Rules collection
resource "azurerm_firewall_application_rule_collection" "fw-app-rule1" {
  name                = "fw-application-rules-browser"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name
  priority            = 102
  action              = "Allow"

  rule {
    name = "AllowBrowser"

    source_addresses = [
      "10.1.1.0/24" //Source addresses of virtual desktops
    ]

    target_fqdns = [
      "*.google.com","*.bing.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "fw-app-rule2" {
  name                = "fw-application-rules-microsoft"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name
  priority            = 101
  action              = "Allow"

  rule {
    name = "AllowMicrosoft"

    source_addresses = [
      "10.1.1.0/24" //Source addresses of virtual desktops
    ]

    target_fqdns = [
      "*.microsoft.com",
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}


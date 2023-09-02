//Subnetwork of the application gateway
resource "azurerm_subnet" "app-gw-sub" {
  name                 = var.appgw-subnetwork
  resource_group_name  = var.resource_group_name
  virtual_network_name = "vnet-apps"
  address_prefixes     = ["10.0.0.0/24"]
}

//Subnetwork of the app services
resource "azurerm_subnet" "appserv-sub" {
  name                 = var.appserv-subnetwork
  resource_group_name  = var.resource_group_name
  virtual_network_name = "vnet-apps"
  address_prefixes     = ["10.0.4.0/24"]
  service_endpoints    = ["Microsoft.Sql","Microsoft.KeyVault"] 
  delegation {
    name = "delegation"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.Web/serverFarms"
    }
  }
}


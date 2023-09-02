//VNET peering between vnet corp and vnet apps to allow communication with Azure Function and SQL Server

resource "azurerm_virtual_network_peering" "peer-vnetapps-to-vnetcorp" {
  name                      = "peer-vnetapps-vnetcorp"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "vnet-apps"
  remote_virtual_network_id = azurerm_virtual_network.vnet-corp.id
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}

resource "azurerm_virtual_network_peering" "peer-vnetcorp-to-vnetapps" {
  name                      = "peer-vnetcorp-vnetapps"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "vnet-main-pro"
  remote_virtual_network_id = var.vnet-apps-id
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}

//Private DNS zone virtual network links (to allow DNS resolution for the private endpoints)

//Private DNS zone virtual network link for Azure function app
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-corp-link1" {
  name                  = "vnet-corp-funcapp-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = "privatelink.azurewebsites.net"
  virtual_network_id    = azurerm_virtual_network.vnet-corp.id
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}

//Private DNS zone virtual network link for SQL server
resource "azurerm_private_dns_zone_virtual_network_link" "vnet-corp-link2" {
  name                  = "vnet-corp-sql-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = "privatelink.database.windows.net"
  virtual_network_id    = azurerm_virtual_network.vnet-corp.id
  depends_on = [
    azurerm_virtual_network.vnet-corp
  ]
}
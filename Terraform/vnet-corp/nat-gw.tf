//NAT gateway 

//Public ip address for the NAT gw
resource "azurerm_public_ip" "nat-gw-public-ip" {
  name                = "nat-gateway-publicIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

//NAT gw resource
resource "azurerm_nat_gateway" "nat-gw" {
  name                    = "ngw-pro-main-01"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
}

//Association of the public ip address with the NAT gw
resource "azurerm_nat_gateway_public_ip_association" "ngw-public-ip-assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat-gw.id
  public_ip_address_id = azurerm_public_ip.nat-gw-public-ip.id
}

//Association of the virtual desktops subnet with the NAT gw so virtual dekstops use the NAT GW public ip address for outbound connectivity
resource "azurerm_subnet_nat_gateway_association" "vddesk-subnet-assoc" {
  subnet_id      = "${azurerm_subnet.vms-virtualdesktop.id}"
  nat_gateway_id = "${azurerm_nat_gateway.nat-gw.id}"
}





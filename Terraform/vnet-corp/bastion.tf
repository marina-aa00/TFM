// Azure Bastion

//Bastion public ip address
resource "azurerm_public_ip" "bastion-ip" {
  name                = "${var.bastion_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method   = "Static"
  sku                 = "Standard"
}

//Azure Bastion resource
resource "azurerm_bastion_host" "bastion" {
  name                   = var.bastion_name
  resource_group_name    = var.resource_group_name
  location               = var.location

  sku                    = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = false
  shareable_link_enabled = false
  tunneling_enabled      = true // Native client support - connect from local computer
  scale_units            = var.scale_units

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion-ip.id
  }

  depends_on = [
    azurerm_public_ip.bastion-ip,
    azurerm_subnet.bastion,
  ]
}

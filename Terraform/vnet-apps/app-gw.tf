//Application gateway configuration

//Public ip address of application gateway

resource "azurerm_public_ip" "pip-app-gw" {
  name                = var.pip_name
  domain_name_label   = "webapps-pay"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static" 
  sku = "Standard"
  zones               = ["1", "2", "3"]
}

//App gateway resource enabled with WAF v2

resource "azurerm_application_gateway" "app-gw" {
  enable_http2        = true
  name                = var.app-gw-name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location


  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2" 
    capacity = 2
  }


  gateway_ip_configuration {
    name      = "appgw-pro-api-payments-01-ip-configuration"
    subnet_id = azurerm_subnet.app-gw-sub.id
  }

  frontend_port {
    name = "http-front-port"
    port = 80
  }

  frontend_port {
    name = "http-front-port2"
    port = 8080
  }

  frontend_ip_configuration {
    name                 = "http-front-ip"
    public_ip_address_id = azurerm_public_ip.pip-app-gw.id
  }

  backend_address_pool {
    name = var.backend-address-pool-name
    fqdns = ["${azurerm_linux_web_app.webapp1.name}.azurewebsites.net"]

  }

  backend_address_pool {
    name = var.backend-address-pool-name2
    fqdns = ["${azurerm_linux_web_app.webapp2.name}.azurewebsites.net"]

  }

  backend_http_settings {
    name                  = var.appgw-http-settings
    cookie_based_affinity = "Disabled"
    port                  = 80 
    protocol              = "Http" 
    request_timeout       = 20
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                  = var.appgw-http-settings2
    cookie_based_affinity = "Disabled"
    port                  = 80 
    protocol              = "Http" 
    request_timeout       = 20
    pick_host_name_from_backend_address = true
  }
  
  http_listener {
    name                           = var.listener-appgw-name
    frontend_ip_configuration_name = "http-front-ip"
    frontend_port_name             = "http-front-port"
    protocol                       = "Http"
  }

   http_listener {
    name                           = var.listener-appgw-name2
    frontend_ip_configuration_name = "http-front-ip"
    frontend_port_name             = "http-front-port2"
    protocol                       = "Http"
  }

  waf_configuration {
    enabled = true
    firewall_mode = "Detection"
    rule_set_type = "OWASP"
    rule_set_version = "3.0"
    request_body_check = true
    max_request_body_size_kb = 128
    file_upload_limit_mb = 100
  }

  request_routing_rule {
    name                       = var.appgw-routing-rule
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = var.listener-appgw-name
    backend_address_pool_name  = var.backend-address-pool-name
    backend_http_settings_name = var.appgw-http-settings
  }

  request_routing_rule {
    name                       = var.appgw-routing-rule2
    priority                   = 101
    rule_type                  = "Basic"
    http_listener_name         = var.listener-appgw-name2
    backend_address_pool_name  = var.backend-address-pool-name2
    backend_http_settings_name = var.appgw-http-settings2
  }

  depends_on = [
    azurerm_public_ip.pip-app-gw,
    azurerm_subnet.app-gw-sub,
  ]
}
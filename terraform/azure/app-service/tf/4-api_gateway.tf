#
# Locals
#

#
# User Assigned Identity
#
resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  name = "${var.prefix}-api-gateway-${var.environment}-${var.location}"
}

#
# Key Vault Access Policy
#
resource "azurerm_key_vault_access_policy" "key_vault_access_policy_api_gateway" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.client_config.tenant_id
  object_id    = azurerm_user_assigned_identity.user_assigned_identity.principal_id

  secret_permissions = [
    "get"
  ]

  certificate_permissions = [
    "get"
  ]

}

#
# Public IP
#
resource "azurerm_public_ip" "public_ip_application_gateway" {
  name                = "${var.prefix}-public-ip-application-gateway-${var.environment}-${var.location}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    owner = var.owner
    environment = var.environment
  }
}

#
# Application Gateway
#
resource "azurerm_application_gateway" "application_gateway" {
  name                = "${var.prefix}-application-gateway-${var.environment}-${var.location}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "application-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet_application_gateway.id
  }


  frontend_ip_configuration {
    name                 = "public_ip"
    public_ip_address_id = azurerm_public_ip.public_ip_application_gateway.id
  }

  backend_address_pool {
    name  = "backend-address-pool"
    fqdns = [azurerm_app_service.app_service.default_site_hostname]
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  backend_http_settings {
    pick_host_name_from_backend_address = true
    name                                = "backend-http-setting"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    probe_name                          = "customprobe"
  }

  http_listener {
    name                           = "listener-80"
    frontend_ip_configuration_name = "public_ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "request-routing-rule-01"
    rule_type                  = "Basic"
    http_listener_name         = "listener-80"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-setting"
  }

  probe {
    pick_host_name_from_backend_http_settings = true
    name                                      = "customprobe"
    protocol                                  = "http"
    path                                      = "/"
    timeout                                   = 30
    interval                                  = 30
    minimum_servers                           = 0
    unhealthy_threshold                       = 3

    match {
      status_code = [
        "200-499",
      ]
    }
  }

  tags = {
    owner = var.owner
    environment = var.environment
    component = "api"
  }
}


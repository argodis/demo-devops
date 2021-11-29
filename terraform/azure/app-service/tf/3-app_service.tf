###
### Resources
###

#
# App Service Plan
#
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.prefix}-app-service-plan-${var.environment}-${var.location}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  kind     = "Linux"
  reserved = true

  sku {
    tier     = "Standard"
    size     = "S1"
    capacity = 1
  }
}

#
# App Service 
#
# This hosts the REST API endpoint.
#
resource "azurerm_app_service" "app_service" {
  name                = "${var.prefix}-app-service-${var.environment}-${var.location}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  https_only          = false

  enabled = true

  app_settings = {
    AZURE_STORAGE_CONNECTION_STRING     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_account_connection_string.id})"
    AZURE_STORAGE_ACCOUNT_NAME          = azurerm_storage_account.storage_account.name
    AZURE_STORAGE_QUEUE_NAME            = azurerm_storage_queue.storage_queue.name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    WEBSITE_VNET_ROUTE_ALL              = "1"
    WEBSITES_PORT                       = 80
    DOCKER_REGISTRY_SERVER_URL          = "https://ghcr.io"
    DOCKER_ENABLE_CI                    = true
  }

  site_config {
    linux_fx_version  = "DOCKER|ghcr.io/0xffea/demo-fractal-api:latest"
    always_on         = true
    ftps_state        = "Disabled"
    health_check_path = "/health"

    ip_restriction {
      name                      = "access-from-application-gateway"
      action                    = "Allow"
      priority                  = 100
      virtual_network_subnet_id =  azurerm_subnet.subnet_application_gateway.id
    }
  }

  # Needed for container logs 
  logs {
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 35
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    component   = "api"
    environment = var.environment
    owner       = var.owner
  }
}

#
# Key Vault Access Policy
#
# Grant read access to key vault for storage connection string.
#
resource "azurerm_key_vault_access_policy" "key_vault_access_policy_app_service" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = azurerm_app_service.app_service.identity[0].tenant_id
  object_id    = azurerm_app_service.app_service.identity[0].principal_id

  # REMOVE DELETE IN PROD
  secret_permissions = [
    "Get",
    "Delete",
  ]
}

#
# Subnet
#
resource "azurerm_subnet" "subnet_app_service" {
  name                 = "subnet-app-service-${var.location}"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.3.0/24"]

  service_endpoints    = ["Microsoft.Web"]
  enforce_private_link_endpoint_network_policies = true

  delegation {
    name = "subnet-app-service-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

#
# App Service Virtual Network Swift Connection
#
resource "azurerm_app_service_virtual_network_swift_connection" "app_service_virtual_network_swift_connection" {
  app_service_id = azurerm_app_service.app_service.id
  subnet_id      = azurerm_subnet.subnet_app_service.id
}

#
# Outputs
#
output "app_service_default_site_hostname" {
  value = azurerm_app_service.app_service.default_site_hostname
}

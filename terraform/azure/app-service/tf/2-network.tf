
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.prefix}-virtual-network-${var.location}"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  # dns_servers

  tags = {
    owner = var.owner
    environment = var.environment
    component = "net"
  }
}

resource "azurerm_subnet" "subnet_linux_virtual_machine" {
  name                 = "subnet-compute-${var.location}"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnet_application_gateway" {
  name                 = "subnet-application-gateway-${var.location}"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = ["Microsoft.Web"]
}

resource "azurerm_network_security_group" "vnet_nsg" {
  name                = "${var.prefix}-network-security-group-${var.environment}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  tags = {
    owner = var.owner
  }
}

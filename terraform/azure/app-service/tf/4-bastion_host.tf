
resource "azurerm_subnet" "bastion_host_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-public-ip-bastion-${var.environment}-${var.location}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    owner = var.owner
    environment = var.environment
  }
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = "${var.prefix}-bastion-host-${var.environment}-${var.location}"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_host_subnet.id
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  tags = {
    owner = var.owner
    environment = var.environment
  }
}

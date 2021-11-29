#
# Locals
#
locals {
  instance_count = 1
}

#
# Resources
#
resource "azurerm_availability_set" "availability_set" {
  name                         = "${var.prefix}-availability-set-${var.environment}-${var.location}"
  location                     = data.azurerm_resource_group.resource_group.location
  resource_group_name          = data.azurerm_resource_group.resource_group.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_network_interface" "network_interface" {
  count               = local.instance_count
  name                = "${var.prefix}-nic${count.index}-${var.environment}-${var.location}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet_linux_virtual_machine.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  count               = local.instance_count
  name                = "${var.prefix}-vm${count.index}-${var.environment}-${var.location}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  size                = "Standard_B2ms"
  availability_set_id = azurerm_availability_set.availability_set.id

  # REMOVE IN PRODUCTION
  admin_username                  = "adminuser"
  admin_password                  = "glen3232!"
  disable_password_authentication = false
  # REMOVE IN PRODUCTION

  network_interface_ids = [
    azurerm_network_interface.network_interface[count.index].id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "virtual_machine_extension" {
  count                      = local.instance_count
  name                       = "hostname${count.index}-${var.environment}-${var.location}"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux_virtual_machine[count.index].id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  protected_settings = <<SETTINGS
    {
        "commandToExecute": "DEBIAN_FRONTEND=noninteractive sudo apt update ; sudo apt --yes upgrade; sudo apt --yes install docker.io; sudo systemctl enable docker; sudo systemctl start docker; docker pull ghcr.io/0xffea/demo-fractal-compute:latest; sudo docker run -d ghcr.io/0xffea/demo-fractal-compute; hostname && uptime"
    }
SETTINGS


  tags = {
    environment = "prod"
    owner       = var.owner
  }
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy_linux_virtual_machine" {
  count        = local.instance_count
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = azurerm_linux_virtual_machine.linux_virtual_machine[count.index].identity.0.tenant_id
  object_id    = azurerm_linux_virtual_machine.linux_virtual_machine[count.index].identity.0.principal_id

  secret_permissions = [
    "Get",
  ]
}

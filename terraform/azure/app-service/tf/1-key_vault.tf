#
# Variables
#
variable "key_vault_name" {
  type    = string
  default = "xffee-key-vault"
}

#
# Resources
#
resource "azurerm_key_vault" "key_vault" {
  name                        = var.key_vault_name
  location                    = data.azurerm_resource_group.resource_group.location
  resource_group_name         = data.azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.client_config.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  tags = {
    owner = var.owner
    environment = var.environment
    component = "config"
  }
}

resource "azurerm_key_vault_access_policy" "azurerm_key_vault_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.client_config.tenant_id
  object_id    = data.azurerm_client_config.client_config.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Purge",
    "Delete",
    "Recover"
  ]

  key_permissions = [
    "Get",
    "Create",
    "List",
    "Purge",
    "Delete",
    "Recover"
  ]

  storage_permissions = [
    "Get",
    "Set",
    "List",
    "Purge",
    "Delete",
    "Recover"
  ]
}

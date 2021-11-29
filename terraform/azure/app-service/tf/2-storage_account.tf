#
# Variables
#
variable "storage_account_name" {
  type    = string
  default = "0xffeasaprod"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "access_tier" {
  type    = string
  default = "Cool"
}

#
# Storage Account
#
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  location                 = data.azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  access_tier              = var.access_tier

  tags = {
    environment = var.environment
    component   = "storage"
    owner       = var.owner
  }
}

#
# Containers
#
resource "azurerm_storage_container" "storage_container" {
  name                  = "${var.prefix}-storage-container-${var.environment}-${var.location}"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

#
# Queues
#
resource "azurerm_storage_queue" "storage_queue" {
  name                 = "${var.prefix}-storage-queue-${var.environment}-${var.location}"
  storage_account_name = azurerm_storage_account.storage_account.name
}

#
# Secrets
#
resource "azurerm_key_vault_secret" "storage_account_connection_string" {
  name         = "storage-account-connection-string"
  value        = azurerm_storage_account.storage_account.primary_connection_string
  key_vault_id = azurerm_key_vault.key_vault.id
}

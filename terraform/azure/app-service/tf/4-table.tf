
###
### Resources
###

#
# Storage Table CONFIGURATION
#
# Used to save configuration data for compute backend
# deployed on VMs.
#

resource "azurerm_storage_table" "storage_table_configuration" {
  name                 = "configuration"
  storage_account_name = azurerm_storage_account.storage_account.name
}

#
# Table Entity CONFIGURATION
#
resource "azurerm_storage_table_entity" "storage_table_entity_configuration_prod" {
  storage_account_name = azurerm_storage_account.storage_account.name
  table_name           = azurerm_storage_table.storage_table_configuration.name

  partition_key = "global"
  row_key       = "prod"

  entity = {
    StorageQueueName = azurerm_storage_queue.storage_queue.name
    StorageContainerName = azurerm_storage_container.storage_container.name
  }
}

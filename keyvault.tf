##############################################################
# Keyvault For System
##############################################################
resource "azurerm_key_vault" "kv_system" {
  name                        = "keyvaultsystem"
  location                    = azurerm_resource_group.rg_system.location
  resource_group_name         = azurerm_resource_group.rg_system.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.system1.id, azurerm_subnet.system2.id]
  }

  access_policy {
    tenant_id      = data.azurerm_client_config.current.tenant_id
    object_id      = data.azurerm_client_config.current.object_id
    application_id = data.azurerm_client_config.current.id

    key_permissions = [
      "Get",
      "Create",
      "Delete"
    ]

    secret_permissions = [
      "Get",
      "Delete"
    ]

    storage_permissions = [
      "Get",
    ]
  }

  tags = merge(local.tags, {
    name = "KeyVault System"
  })
}

##############################################################
# Keyvault For Confidentiel
##############################################################
resource "azurerm_key_vault" "kv_confidentiel" {
  name                        = "keyvaultconfidentiel"
  location                    = azurerm_resource_group.rg_confidentiel.location
  resource_group_name         = azurerm_resource_group.rg_confidentiel.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.confidentiel1.id]
  }

  access_policy {
    tenant_id      = data.azurerm_client_config.current.tenant_id
    object_id      = data.azurerm_client_config.current.object_id
    application_id = data.azurerm_client_config.current.id

    key_permissions = [
      "Get",
      "Create",
      "Delete"
    ]

    secret_permissions = [
      "Get",
      "Delete"
    ]

    storage_permissions = [
      "Get",
    ]
  }

  tags = merge(local.tags, {
    name = "KeyVault Confidentiel"
  })
}

##############################################################
# Key Vault Policy System
##############################################################
resource "azurerm_key_vault_access_policy" "system" {
  key_vault_id   = azurerm_key_vault.kv_confidentiel.id
  tenant_id      = data.azurerm_client_config.current.tenant_id
  object_id      = data.azurerm_client_config.current.object_id
  application_id = data.azurerm_client_config.current.client_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
  depends_on = [
    azurerm_key_vault.kv_system
  ]
}

##############################################################
# Key Vault Policy Confidentiel
##############################################################
resource "azurerm_key_vault_access_policy" "confidentiel" {
  key_vault_id   = azurerm_key_vault.kv_system.id
  tenant_id      = data.azurerm_client_config.current.tenant_id
  object_id      = data.azurerm_client_config.current.object_id
  application_id = data.azurerm_client_config.current.client_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
  depends_on = [
    azurerm_key_vault.kv_confidentiel
  ]
}


##############################################################
# Keyvault For System
##############################################################
resource "azurerm_key_vault" "kv_system" {
  # checkov:skip=CKV_AZURE_110: ADD REASON
  # checkov:skip=CKV_AZURE_42: ADD REASON
  name                        = "keyvaultcpesystem"
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
    ip_rules                   = ["0.0.0.0/0"]
  }


  tags = merge(local.tags, {
    name = "KeyVault System"
  })
}

##############################################################
# Keyvault For Confidentiel
##############################################################
resource "azurerm_key_vault" "kv_confidentiel" {
  # checkov:skip=CKV_AZURE_110: ADD REASON
  # checkov:skip=CKV_AZURE_42: ADD REASON
  name                        = "keyvaultcpeconfidentiel"
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
    ip_rules                   = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    name = "KeyVault Confidentiel"
  })
}

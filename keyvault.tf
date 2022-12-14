##############################################################
# Key Vault Policy Confidentiel
##############################################################
resource "azurerm_key_vault_access_policy" "confidentiel" {
  key_vault_id   = azurerm_key_vault.kv_confidentiel.id
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
# Key Vault Policy System
##############################################################
resource "azurerm_key_vault_access_policy" "system" {
  key_vault_id   = azurerm_key_vault.kv_system.id
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
# Key Vault Policy Group IT - Confidentiel
##############################################################
resource "azurerm_key_vault_access_policy" "it_confidentiel" {
  key_vault_id = azurerm_key_vault.kv_confidentiel.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_group.it.object_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_key_vault.kv_system,
    azurerm_key_vault.kv_confidentiel
  ]
}

##############################################################
# Key Vault Policy Group IT - System
##############################################################
resource "azurerm_key_vault_access_policy" "it_system" {
  key_vault_id = azurerm_key_vault.kv_system.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_group.it.object_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_key_vault.kv_system,
    azurerm_key_vault.kv_confidentiel
  ]
}

##############################################################
# Key Vault Policy Group Administratif - System
##############################################################
resource "azurerm_key_vault_access_policy" "administratif_system" {
  key_vault_id = azurerm_key_vault.kv_system.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_group.administratif.object_id

  key_permissions    = ["Get", "Create", "Delete", "List"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_key_vault.kv_system,
    azurerm_key_vault.kv_confidentiel
  ]
}

##############################################################
# Key Vault Policy Group Administratif - Confidentiel
##############################################################
resource "azurerm_key_vault_access_policy" "administratif_confidentiel" {
  key_vault_id = azurerm_key_vault.kv_confidentiel.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_group.administratif.object_id

  key_permissions    = ["Get", "Create", "Delete", "List"]
  secret_permissions = ["Get"]

  depends_on = [
    azurerm_key_vault.kv_system,
    azurerm_key_vault.kv_confidentiel
  ]
}

##############################################################
# Key Vault Policy Storage Account
##############################################################
resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = azurerm_key_vault.kv_confidentiel.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.confidentiel_sg.identity[0].principal_id

  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

##############################################################
# Keyvault For System
##############################################################
resource "azurerm_key_vault" "kv_system" {
  name                        = "kvsystemCPE"
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
  name                        = "kvconfidentielCPE"
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

##############################################################
# Keyvault Logs System
##############################################################
resource "azurerm_monitor_diagnostic_setting" "log_system" {
  name                       = "diagnostic-setting-system"
  target_resource_id         = azurerm_key_vault.kv_system.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.wss.id

  log {
    category = "AuditEvent"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

##############################################################
# Keyvault Logs Confidentiel
##############################################################
resource "azurerm_monitor_diagnostic_setting" "log_confidentiel" {
  name                       = "diagnostic-setting-confidentiel"
  target_resource_id         = azurerm_key_vault.kv_confidentiel.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.wsc.id

  log {
    category = "AuditEvent"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

##############################################################
# Key Vault Key For Storage Account
##############################################################
resource "azurerm_key_vault_key" "kvk" {
  # checkov:skip=CKV_AZURE_112:  No HSM
  name            = "StorageAccount-Key"
  key_vault_id    = azurerm_key_vault.kv_confidentiel.id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  expiration_date = "2023-12-30T20:00:00Z"
  depends_on = [
    azurerm_key_vault_access_policy.confidentiel,
    azurerm_key_vault_access_policy.storage
  ]
}

##############################################################
# Storage Account
##############################################################
resource "azurerm_storage_account" "confidentiel_sg" {
  name                     = "confidentielsg"
  resource_group_name      = azurerm_resource_group.rg_confidentiel.name
  location                 = azurerm_resource_group.rg_confidentiel.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"

  identity {
    type = "SystemAssigned"
  }

  queue_properties {

    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }

    hour_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }

    minute_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = ["0.0.0.0/0"]
    virtual_network_subnet_ids = [azurerm_subnet.confidentiel1.id, azurerm_subnet.confidentiel2.id]
  }

  tags = merge(local.tags, {
    description = "Confidentiel Storage Account"
  })
}

##############################################################
# Storage Account Customer Managed Key
##############################################################
resource "azurerm_storage_account_customer_managed_key" "cmk" {
  storage_account_id = azurerm_storage_account.confidentiel_sg.id
  key_vault_id       = azurerm_key_vault.kv_confidentiel.id
  key_name           = azurerm_key_vault_key.kvk.name
  depends_on = [
    azurerm_key_vault.kv_confidentiel,
    azurerm_key_vault_key.kvk
  ]
}

##############################################################
# Storage Share
##############################################################
resource "azurerm_storage_share" "confidentiel_ss" {
  name                 = "fileshare-confidentiel"
  storage_account_name = azurerm_storage_account.confidentiel_sg.name
  quota                = 250
  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2022-12-10T09:38:21.0000000Z"
      expiry      = "2023-07-02T10:38:21.0000000Z"
    }
  }
}

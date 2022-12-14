##############################################################
# Recovery Service
##############################################################
resource "azurerm_recovery_services_vault" "rsv" {
  name                = "recovery-vault"
  location            = azurerm_resource_group.rg_confidentiel.location
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
  sku                 = "Standard"
  soft_delete_enabled = false
}

##############################################################
# Backup Policy
##############################################################
resource "azurerm_backup_policy_vm" "rvp" {
  name                = "recovery-vault-policy"
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }
}

##############################################################
# Apply Backup On Confidential VM
##############################################################
resource "azurerm_backup_protected_vm" "backupvmconf" {
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  source_vm_id        = azurerm_virtual_machine.vmconfidentiel.id
  backup_policy_id    = azurerm_backup_policy_vm.rvp.id
}

resource "azurerm_recovery_services_vault" "rsv" {
  name                = "recovery-vault"
  location            = azurerm_resource_group.rg_confidentiel.location
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "rvp" {
  name                = "recovery-vault-policy"
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  timezone            = "UTC+1"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }
}

data "azurerm_virtual_machine" "vmconf" {
  name                = "vmconfidentiel"
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
}

resource "azurerm_backup_protected_vm" "backupvmconf" {
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  source_vm_id        = data.azurerm_virtual_machine.vmconf.id
  backup_policy_id    = azurerm_backup_policy_vm.rvp.id
}

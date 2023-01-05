##############################################################
# Resource Groups
##############################################################
resource "azurerm_resource_group" "rg_system" {
  name     = "RG_SYSTEM_TERRAFORM"
  location = "North Europe"

  tags = merge(local.tags, {
    name = "System Resource Group"
  })
}

resource "azurerm_resource_group" "rg_confidentiel" {
  name     = "RG_CONFIDENTIEL_TERRAFORM"
  location = "North Europe"

  tags = merge(local.tags, {
    name = "Confidentiel Resource Group"
  })
}

##############################################################
# Log Analytics Workspace
##############################################################
resource "azurerm_log_analytics_workspace" "wsc" {
  name                = "Workspace_confidentiel"
  location            = azurerm_resource_group.rg_confidentiel.location
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_workspace" "wss" {
  name                = "Workspace_system"
  location            = azurerm_resource_group.rg_system.location
  resource_group_name = azurerm_resource_group.rg_system.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

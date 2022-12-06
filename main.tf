##############################################################
# Resource Group
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

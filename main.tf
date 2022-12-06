##############################################################
# Resource Group
##############################################################
resource "azurerm_resource_group" "rg_system" {
  name     = "RG_SYSTEM_TERRAFORM"
  location = "North Europe"
}

resource "azurerm_resource_group" "rg_confidentiel" {
  name     = "RG_CONFIDENTIEL_TERRAFORM"
  location = "North Europe"
}



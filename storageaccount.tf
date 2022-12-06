##############################################################
# Storage Account
##############################################################
resource "azurerm_storage_account" "confidentiel_sg" {
  name                     = "Confidentiel_SG"
  resource_group_name      = azurerm_resource_group.rg_confidentiel.name
  location                 = azurerm_resource_group.rg_confidentiel.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    Terraform = "True"
  }
}

##############################################################
# Storage Share
##############################################################
resource "azurerm_storage_share" "confidentiel_ss" {
  name                 = "fileshare-confidentiel"
  storage_account_name = azurerm_storage_account.confidentiel_sg.name
  quota                = 250
}

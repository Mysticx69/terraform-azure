##############################################################
# Storage Account
##############################################################
resource "azurerm_storage_account" "example" {
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.rg_confidentiel.name
  location                 = azurerm_resource_group.rg_confidentiel.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    Terraform = "True"
  }
}

resource "azurerm_storage_share" "example" {
  name                 = "fileshare-confidentiel"
  storage_account_name = azurerm_storage_account.example.name
  quota                = 250
}

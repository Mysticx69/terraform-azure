##############################################################
# Network Security Groups
##############################################################
resource "azurerm_network_security_group" "AllowSSHRDPInbound" {
  name                = "AllowSSH_RDP_Inbound"
  location            = azurerm_resource_group.rg_system.location
  resource_group_name = azurerm_resource_group.rg_system.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "134.214.51.172"
    destination_address_prefix = "*"
  }

  tags = {
    Terraform = "True"
  }
}

##############################################################
# Virtual Network System
##############################################################
resource "azurerm_virtual_network" "system" {
  name                = "SuperNet-System-TF"
  location            = azurerm_resource_group.rg_system.location
  resource_group_name = azurerm_resource_group.rg_system.name
  address_space       = ["10.200.0.0/16"]

  tags = {
    Terraform = "True"
  }
}

##############################################################
# Subnets System 1
##############################################################
resource "azurerm_subnet" "system1" {
  name                 = "subnet-system-1-TF"
  resource_group_name  = azurerm_resource_group.rg_system.name
  virtual_network_name = azurerm_virtual_network.system.name
  address_prefixes     = ["10.200.0.0/24"]
}

##############################################################
# Subnets System 2
##############################################################
resource "azurerm_subnet" "system2" {
  name                 = "subnet-system-2-TF"
  resource_group_name  = azurerm_resource_group.rg_system.name
  virtual_network_name = azurerm_virtual_network.system.name
  address_prefixes     = ["10.200.1.0/24"]
}

##############################################################
# Subnets And Network Security Association
##############################################################
resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.system1.id
  network_security_group_id = azurerm_network_security_group.AllowSSHRDPInbound.id
}

##############################################################
# Virtual Network Confidentiel
##############################################################
resource "azurerm_virtual_network" "confidentiel" {
  name                = "SuperNet-confidentiel-TF"
  location            = azurerm_resource_group.rg_confidentiel.location
  resource_group_name = azurerm_resource_group.rg_confidentiel.name
  address_space       = ["10.201.0.0/16"]

  tags = {
    Terraform = "True"
  }
}

##############################################################
# Subnets Confidentiel 1
##############################################################
resource "azurerm_subnet" "confidentiel1" {
  name                 = "subnet-confidentiel-1-TF"
  resource_group_name  = azurerm_resource_group.rg_confidentiel.name
  virtual_network_name = azurerm_virtual_network.confidentiel.name
  address_prefixes     = ["10.201.0.0/24"]
}

##############################################################
# Subnets Confidentiel 2
##############################################################
resource "azurerm_subnet" "confidentiel2" {
  name                 = "subnet-confidentiel-2-TF"
  resource_group_name  = azurerm_resource_group.rg_confidentiel.name
  virtual_network_name = azurerm_virtual_network.confidentiel.name
  address_prefixes     = ["10.201.1.0/24"]
}








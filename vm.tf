##############################################################
# Public IP
##############################################################
resource "azurerm_public_ip" "bastion_ip" {
  name                = "PublicIpBastion"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    Terraform = "True"
  }
}

##############################################################
# Network Interface => system subnet
##############################################################
resource "azurerm_network_interface" "mainsystem" {
  # checkov:skip=CKV_AZURE_119: Ensure that Network Interfaces don't use public IPs => Needed
  name                = "bastion-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "networconfig-system"
    subnet_id                     = azurerm_subnet.system1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_ip.id
  }
}

##############################################################
# Network Interface => confidentiel subnet
##############################################################
resource "azurerm_network_interface" "mainconfidentiel" {
  name                = "bastion-nic"
  location            = azurerm_resource_group.rg_confidentiel.location
  resource_group_name = azurerm_resource_group.rg_confidentiel.name

  ip_configuration {
    name                          = "networconfig-confidentiel"
    subnet_id                     = azurerm_subnet.confidentiel1.id
    private_ip_address_allocation = "Dynamic"
  }
}


##############################################################
# Virtual Machine Windows Server 2019 => System subnet
##############################################################
resource "azurerm_virtual_machine" "bastion_vm" {
  name                             = "Bastion-vm"
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.mainsystem.id]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true


  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "asterna"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = false
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    Terraform = "True"
  }
}

##############################################################
# Virtual Machine Windows Server 2019 => confidentiel subnet
##############################################################
resource "azurerm_virtual_machine" "vmconfidentiel" {
  name                             = "WINSERV2019"
  location                         = azurerm_resource_group.rg_confidentiel.location
  resource_group_name              = azurerm_resource_group.rg_confidentiel.name
  network_interface_ids            = [azurerm_network_interface.mainconfidentiel.id]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "asterna"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = false
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    Terraform = "True"
  }
}

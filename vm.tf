##############################################################
# Public IP
##############################################################
resource "azurerm_public_ip" "bastion_ip" {
  name                = "PublicIpBastion"
  resource_group_name = azurerm_resource_group.rg_system.name
  location            = azurerm_resource_group.rg_system.location
  allocation_method   = "Static"

  tags = merge(local.tags, {
    description = "PublicIP For Bastion VM"
  })
}

##############################################################
# Network Interface => system subnet
##############################################################
resource "azurerm_network_interface" "mainsystem" {
  # checkov:skip=CKV_AZURE_119: Ensure that Network Interfaces don't use public IPs => Needed
  name                = "bastion-nic"
  location            = azurerm_resource_group.rg_system.location
  resource_group_name = azurerm_resource_group.rg_system.name

  ip_configuration {
    name                          = "networconfig-system"
    subnet_id                     = azurerm_subnet.system1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_ip.id
  }

  tags = merge(local.tags, {
    description = "Main Interface For Bastion Vm"
  })
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

  tags = merge(local.tags, {
    description = "Main Interface For Confidentiel Vm"
  })
}


##############################################################
# Virtual Machine Windows Server 2019 => System subnet
##############################################################
resource "azurerm_virtual_machine" "bastion_vm" {
  # checkov:skip=CKV2_AZURE_12: Backup => TODO
  name                             = "Bastion-vm"
  location                         = azurerm_resource_group.rg_system.location
  resource_group_name              = azurerm_resource_group.rg_system.name
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

  tags = merge(local.tags, {
    name = "Bastion VM"
  })
}

##############################################################
# Virtual Machine Extension
##############################################################
resource "azurerm_virtual_machine_extension" "extension_bastion_vm" {
  name                       = "bastion_vm"
  virtual_machine_id         = azurerm_virtual_machine.bastion_vm.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
}

##############################################################
# Virtual Machine Windows Server 2019 => confidentiel subnet
##############################################################
resource "azurerm_virtual_machine" "vmconfidentiel" {
  # checkov:skip=CKV2_AZURE_12: Backup => TODO
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

  tags = merge(local.tags, {
    name = "Confidentiel VM"
  })
}

##############################################################
# Virtual Machine Extension
##############################################################
resource "azurerm_virtual_machine_extension" "extension_vmconfidentiel" {
  name                       = "vmconfidentiel"
  virtual_machine_id         = azurerm_virtual_machine.vmconfidentiel.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
}

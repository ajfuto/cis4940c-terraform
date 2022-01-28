provider "azurerm" {
  features {}
}

// some global settings...

resource "azurerm_resource_group" "resource" {
  name                            = "example-resources"
  location                        = "West Europe"
}

resource "azurerm_virtual_network" "network" {
  name                            = "example-network"
  address_space                   = ["10.0.0.0/16"]
  location                        = azurerm_resource_group.resource.location
  resource_group_name             = azurerm_resource_group.resource.name
}

resource "azurerm_subnet" "example" {
  name                            = "internal"
  resource_group_name             = azurerm_resource_group.resource.name
  virtual_network_name            = azurerm_virtual_network.network.name
  address_prefixes                = ["10.0.2.0/24"]
}

// resources for linux VM

resource "azurerm_public_ip" "public-ip" {
  name                            = "${var.prefix}-public-ip"
  resource_group_name             = azurerm_resource_group.resource.name
  location                        = azurerm_resource_group.resource.location
  allocation_method               = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                            = "linux-nic"
  location                        = azurerm_resource_group.resource.location
  resource_group_name             = azurerm_resource_group.resource.name

  ip_configuration {
	name                          = "internal"
	subnet_id                     = azurerm_subnet.example.id
	private_ip_address_allocation = "Dynamic"
	public_ip_address_id          = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "linux-example" {
  name                            = "linux-machine"
  resource_group_name             = azurerm_resource_group.resource.name
  location                        = azurerm_resource_group.resource.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  network_interface_ids           = [
	azurerm_network_interface.nic.id,
  ]

  os_disk {
	caching                       = "ReadWrite"
	storage_account_type          = "Standard_LRS"
  }

  source_image_reference {
	publisher                     = "Canonical"
	offer                         = "UbuntuServer"
	sku                           = "16.04-LTS"
	version                       = "latest"
  }
}

// resources for windows VM

resource "azurerm_public_ip" "public-ip-2" {
  name                            = "${var.prefix}-public-ip-2"
  resource_group_name             = azurerm_resource_group.resource.name
  location                        = azurerm_resource_group.resource.location
  allocation_method               = "Dynamic"
}

resource "azurerm_network_interface" "nic-2" {
  name                            = "win-nic"
  location                        = azurerm_resource_group.resource.location
  resource_group_name             = azurerm_resource_group.resource.name

  ip_configuration {
	name                          = "internal"
	subnet_id                     = azurerm_subnet.example.id
	private_ip_address_allocation = "Dynamic"
	public_ip_address_id          = azurerm_public_ip.public-ip-2.id
	
  }
}

resource "azurerm_windows_virtual_machine" "win-example" {
  name                            = "win-machine"
  resource_group_name             = azurerm_resource_group.resource.name
  location                        = azurerm_resource_group.resource.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  network_interface_ids           = [
	azurerm_network_interface.nic-2.id,
  ]

  os_disk {
	caching                       = "ReadWrite"
	storage_account_type          = "Standard_LRS"
  }

  source_image_reference {
	publisher                     = "MicrosoftWindowsServer"
	offer                         = "WindowsServer"
	sku                           = "2016-Datacenter"
	version                       = "latest"
  }
}

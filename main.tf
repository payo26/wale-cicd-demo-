terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "790aa1f8-6209-43c8-8546-2cbff23d845f"
}

terraform {
  required_version = ">= 1.0.0"
 backend "azurerm" {
  resource_group_name  = "wale-rg"
  storage_account_name = "tfstate"
  password             = "waletfstate"
}
}

# Create a resource group
resource "azurerm_resource_group" "prayo_rg" {
  name     = "prayo-rg"
  location = "East US"
}

# Create a virtual network
resource "azurerm_virtual_network" "prayo_vnet" {
  name                = "prayo-vnet"
  resource_group_name = azurerm_resource_group.prayo_rg.name
  location            = azurerm_resource_group.prayo_rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "prayo_subnet" {
  name                 = "prayo-subnet"
  resource_group_name  = azurerm_resource_group.prayo_rg.name
  virtual_network_name = azurerm_virtual_network.prayo_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#create a public ip
resource "azurerm_public_ip" "prayo_ip" {
  name                = "prayo-ip"
  resource_group_name = azurerm_resource_group.prayo_rg.name
  location            = azurerm_resource_group.prayo_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#create network security group 
resource "azurerm_network_security_group" "prayo_nsg" {
  name                = "prayo-nsg"
  resource_group_name = azurerm_resource_group.prayo_rg.name
  location            = azurerm_resource_group.prayo_rg.location

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#create network interface
resource "azurerm_network_interface" "prayo_nic" {
  name                = "prayo-nic"
  location            = azurerm_resource_group.prayo_rg.location
  resource_group_name = azurerm_resource_group.prayo_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prayo_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.prayo_ip.id
  }
}

#associate the network security group with the subnet
resource "azurerm_subnet_network_security_group_association" "prayo_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.prayo_subnet.id
  network_security_group_id = azurerm_network_security_group.prayo_nsg.id
}

#create a virtual machine
resource "azurerm_linux_virtual_machine" "prayo_vm" {
  name                = "prayo-vm"
  resource_group_name = azurerm_resource_group.prayo_rg.name
  location            = azurerm_resource_group.prayo_rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.prayo_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Output the public IP address of the virtual machine
output "public_ip_address" {
  value = azurerm_public_ip.prayo_ip.ip_address
}






terraform {
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
  resource_group_name  = "maydoy-rg"
  storage_account_name = "maydoytfstate"
  password             = "maydoytfstate"
}
}

# Create a resource group
resource "azurerm_resource_group" "maydoy-rg" {
  name     = "maydoy-rg"
  location = "East US"
}

# Create a virtual network
resource "azurerm_virtual_network" "maydoy-vnet" {
  name                = "maydoy-vnet"
  resource_group_name = azurerm_resource_group.maydoy-rg.name
  location            = azurerm_resource_group.maydoy-rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "maydoy-subnet" {
  name                 = "maydoy-subnet"
  resource_group_name  = azurerm_resource_group.maydoy-rg.name
  virtual_network_name = azurerm_virtual_network.maydoy-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "maydoy-nsg" {
  name                = "maydoy-nsg"
  location            = azurerm_resource_group.maydoy-rg.location
  resource_group_name = azurerm_resource_group.maydoy-rg.name

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

#create a public IP address
resource "azurerm_public_ip" "maydoy-pip" {
  name                = "maydoy-pip"
  location            = azurerm_resource_group.maydoy-rg.location
  resource_group_name = azurerm_resource_group.maydoy-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#create a network interface
resource "azurerm_network_interface" "maydoy-nic" {
  name                = "maydoy-nic"
  location            = azurerm_resource_group.maydoy-rg.location
  resource_group_name = azurerm_resource_group.maydoy-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.maydoy-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.maydoy-pip.id
  }
}

#associate the network security group with the subnet
resource "azurerm_subnet_network_security_group_association" "maydoy-subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.maydoy-subnet.id
  network_security_group_id = azurerm_network_security_group.maydoy-nsg.id
}

#create a virtual machine
resource "azurerm_linux_virtual_machine" "maydoy-vm" {
  name                = "maydoy-vm"
  resource_group_name = azurerm_resource_group.maydoy-rg.name
  location            = azurerm_resource_group.maydoy-rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.maydoy-nic.id,
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
  value = azurerm_public_ip.maydoy-pip.ip_address
}

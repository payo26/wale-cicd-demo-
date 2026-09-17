output "vm public ip" {
  value = azurerm_public_ip.maydoy-pip.ip_address   
}

output "vm private ip" {
  value = azurerm_network_interface.maydoy-nic.private_ip_address
}

output "resource group name" {
  value = azurerm_resource_group.maydoy-rg.name
}

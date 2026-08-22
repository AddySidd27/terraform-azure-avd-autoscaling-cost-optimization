output "vnet_name" { value = azurerm_virtual_network.this.name }
output "vnet_id" { value = azurerm_virtual_network.this.id }
output "session_host_subnet_id" { value = azurerm_subnet.session_hosts.id }
output "session_host_subnet_name" { value = azurerm_subnet.session_hosts.name }

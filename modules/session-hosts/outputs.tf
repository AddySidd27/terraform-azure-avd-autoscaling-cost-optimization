output "session_host_names" { value = azurerm_windows_virtual_machine.this[*].name }
output "session_host_resource_ids" { value = azurerm_windows_virtual_machine.this[*].id }
output "session_host_principal_ids" { value = azurerm_windows_virtual_machine.this[*].identity[0].principal_id }

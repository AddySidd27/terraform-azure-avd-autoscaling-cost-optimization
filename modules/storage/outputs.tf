output "storage_account_id" { value = azurerm_storage_account.this.id }
output "storage_account_name" { value = azurerm_storage_account.this.name }
output "file_share_id" { value = azurerm_storage_share.fslogix.id }
output "file_share_name" { value = azurerm_storage_share.fslogix.name }
output "fslogix_unc_path" {
  value = "\\\\${azurerm_storage_account.this.name}.file.core.windows.net\\${azurerm_storage_share.fslogix.name}"
}

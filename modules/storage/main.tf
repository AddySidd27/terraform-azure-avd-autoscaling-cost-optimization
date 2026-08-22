resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.replication_type

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  shared_access_key_enabled       = true
  default_to_oauth_authentication = true

  azure_files_authentication {
    directory_type                 = "AADKERB"
    default_share_level_permission = "None"
  }

  tags = var.tags
}

resource "azurerm_storage_share" "fslogix" {
  name               = var.fslogix_share_name
  storage_account_id = azurerm_storage_account.this.id
  quota              = var.fslogix_share_quota_gb
}

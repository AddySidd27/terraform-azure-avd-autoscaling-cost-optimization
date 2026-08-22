resource "azurerm_virtual_desktop_host_pool" "this" {
  name                     = var.host_pool_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  type                     = var.host_pool_type
  friendly_name            = var.host_pool_name
  description              = "Pooled Azure Virtual Desktop host pool managed by Terraform."
  validate_environment     = false
  start_vm_on_connect      = var.start_vm_on_connect
  load_balancer_type       = var.load_balancer_type
  maximum_sessions_allowed = var.maximum_sessions_allowed
  preferred_app_group_type = "Desktop"
  public_network_access    = "Enabled"

  custom_rdp_properties = "enablerdsaadauth:i:1;"

  tags = var.tags
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = var.application_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.this.id
  friendly_name       = var.application_group_name
  description         = "Desktop application group for the Terraform-managed AVD host pool."
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = var.workspace_name
  description         = "Azure Virtual Desktop workspace managed by Terraform."
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "desktop" {
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = timeadd(var.registration_base_time, "23h")
}

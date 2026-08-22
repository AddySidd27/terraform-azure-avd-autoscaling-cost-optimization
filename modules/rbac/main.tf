resource "azurerm_role_assignment" "avd_user" {
  scope                = var.application_group_id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.avd_user_group_object_id
}

resource "azurerm_role_assignment" "vm_user_login" {
  count                = length(var.session_host_resource_ids)
  scope                = var.session_host_resource_ids[count.index]
  role_definition_name = "Virtual Machine User Login"
  principal_id         = var.avd_user_group_object_id
}

resource "azurerm_role_assignment" "storage_smb_contributor" {
  scope                = var.file_share_id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = var.avd_user_group_object_id
}

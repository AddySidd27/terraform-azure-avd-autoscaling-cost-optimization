resource "azurerm_network_interface" "this" {
  count               = var.session_host_count
  name                = "nic-${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "this" {
  count                 = var.session_host_count
  name                  = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  computer_name         = "${var.vm_name_prefix}${format("%02d", count.index + 1)}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.this[count.index].id]

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true
  license_type        = "Windows_Client"

  identity {
    type = "SystemAssigned"
  }

  automatic_updates_enabled = true

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  count                      = var.session_host_count
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_run_command" "avd_agent" {
  count              = var.session_host_count
  name               = "install-avd-agent"
  location           = var.location
  virtual_machine_id = azurerm_windows_virtual_machine.this[count.index].id

  source {
    script = file("${path.root}/scripts/install-avd-agent.ps1")
  }

  protected_parameter {
    name  = "RegistrationToken"
    value = var.avd_registration_token
  }

  tags = var.tags

  depends_on = [azurerm_virtual_machine_extension.aad_login]
}

resource "azurerm_virtual_machine_run_command" "fslogix" {
  count              = var.session_host_count
  name               = "configure-fslogix"
  location           = var.location
  virtual_machine_id = azurerm_windows_virtual_machine.this[count.index].id

  source {
    script = file("${path.root}/scripts/configure-fslogix.ps1")
  }

  parameter {
    name  = "FslogixUncPath"
    value = var.fslogix_unc_path
  }

  tags = var.tags

  depends_on = [azurerm_virtual_machine_run_command.avd_agent]
}

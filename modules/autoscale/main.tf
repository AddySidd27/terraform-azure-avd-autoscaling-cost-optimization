resource "azurerm_role_assignment" "autoscale_power_management" {
  scope                            = "/subscriptions/${var.subscription_id}"
  role_definition_name             = "Desktop Virtualization Power On Off Contributor"
  principal_id                     = var.avd_service_principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "start_vm_on_connect" {
  scope                            = "/subscriptions/${var.subscription_id}"
  role_definition_name             = "Desktop Virtualization Power On Contributor"
  principal_id                     = var.avd_service_principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_virtual_desktop_scaling_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = var.name
  description         = "Native AVD power-management autoscale plan managed by Terraform."
  time_zone           = var.time_zone
  exclusion_tag       = var.exclusion_tag

  dynamic "schedule" {
    for_each = var.schedules

    content {
      name                                 = schedule.value.name
      days_of_week                         = schedule.value.days_of_week
      ramp_up_start_time                   = schedule.value.ramp_up_start_time
      ramp_up_load_balancing_algorithm     = "BreadthFirst"
      ramp_up_minimum_hosts_percent        = schedule.value.ramp_up_minimum_hosts_percent
      ramp_up_capacity_threshold_percent   = schedule.value.ramp_up_capacity_threshold_percent
      peak_start_time                      = schedule.value.peak_start_time
      peak_load_balancing_algorithm        = "BreadthFirst"
      ramp_down_start_time                 = schedule.value.ramp_down_start_time
      ramp_down_load_balancing_algorithm   = "DepthFirst"
      ramp_down_minimum_hosts_percent      = schedule.value.ramp_down_minimum_hosts_percent
      ramp_down_force_logoff_users         = schedule.value.ramp_down_force_logoff_users
      ramp_down_wait_time_minutes          = schedule.value.ramp_down_wait_time_minutes
      ramp_down_notification_message       = "This session host is shutting down for scheduled cost optimization. Save your work and sign out."
      ramp_down_capacity_threshold_percent = schedule.value.ramp_down_capacity_threshold_percent
      ramp_down_stop_hosts_when            = schedule.value.ramp_down_stop_hosts_when
      off_peak_start_time                  = schedule.value.off_peak_start_time
      off_peak_load_balancing_algorithm    = "DepthFirst"
    }
  }

  host_pool {
    hostpool_id          = var.host_pool_id
    scaling_plan_enabled = true
  }

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.autoscale_power_management,
    azurerm_role_assignment.start_vm_on_connect
  ]
}

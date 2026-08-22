output "scaling_plan_name" {
  value = azurerm_virtual_desktop_scaling_plan.this.name
}

output "schedule_summary" {
  value = {
    time_zone = var.time_zone
    schedules = var.schedules
  }
}

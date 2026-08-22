output "resource_group_name" {
  value       = module.resource_group.name
  description = "AVD resource group name."
}

output "vnet_name" {
  value       = module.networking.vnet_name
  description = "AVD virtual network name."
}

output "host_pool_name" {
  value       = module.avd.host_pool_name
  description = "AVD host pool name."
}

output "workspace_name" {
  value       = module.avd.workspace_name
  description = "AVD workspace name."
}

output "application_group_name" {
  value       = module.avd.application_group_name
  description = "AVD desktop application group name."
}

output "session_host_names" {
  value       = module.session_hosts.session_host_names
  description = "Session host VM names."
}

output "storage_account_name" {
  value       = module.storage.storage_account_name
  description = "Azure Files storage account name."
}

output "fslogix_unc_path" {
  value       = module.storage.fslogix_unc_path
  description = "FSLogix profile container UNC path."
}

output "scaling_plan_name" {
  value       = module.autoscale.scaling_plan_name
  description = "Native AVD scaling plan assigned to the pooled host pool."
}

output "autoscale_schedule" {
  value       = module.autoscale.schedule_summary
  description = "Configured autoscale phase times and time zone."
}

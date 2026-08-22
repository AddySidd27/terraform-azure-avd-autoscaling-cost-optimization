variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider."
  type        = string
  sensitive   = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id)) && var.subscription_id != "00000000-0000-0000-0000-000000000000"
    error_message = "subscription_id must be a valid GUID. Replace the zero-value placeholder from terraform.tfvars.example."
  }
}

variable "project_name" {
  description = "Short lowercase project identifier used in resource names."
  type        = string
  default     = "avd"
  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.project_name))
    error_message = "project_name must be 2-12 characters and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "VNet address space."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "session_host_subnet_prefixes" {
  description = "Address prefixes for the session-host subnet."
  type        = list(string)
  default     = ["10.20.1.0/24"]
}

variable "session_host_count" {
  description = "Number of session hosts."
  type        = number
  default     = 2
  validation {
    condition     = var.session_host_count >= 1 && var.session_host_count <= 50
    error_message = "session_host_count must be between 1 and 50."
  }
}

variable "session_host_vm_size" {
  description = "Azure VM size for session hosts."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "windows_image_publisher" {
  description = "Marketplace image publisher."
  type        = string
  default     = "MicrosoftWindowsDesktop"
}

variable "windows_image_offer" {
  description = "Marketplace image offer."
  type        = string
  default     = "office-365"
}

variable "windows_image_sku" {
  description = "Marketplace image SKU. Windows 11 Enterprise multi-session + Microsoft 365 is recommended for the default pooled scenario."
  type        = string
  default     = "win11-24h2-avd-m365"
}

variable "windows_image_version" {
  description = "Exact Marketplace image version. Set this to a version available in your region; do not use latest for reproducible deployments."
  type        = string
}

variable "admin_username" {
  description = "Local administrator username for session hosts."
  type        = string
  default     = "avdadmin"
  sensitive   = false
}

variable "admin_password" {
  description = "Local administrator password for session hosts. Store securely and never commit it."
  type        = string
  sensitive   = true
  validation {
    condition = (
      length(var.admin_password) >= 12 &&
      length(var.admin_password) <= 123 &&
      var.admin_password != "<GENERATE-A-STRONG-PASSWORD-AND-PASS-SECURELY>"
    )
    error_message = "admin_password must be 12-123 characters and must replace the placeholder in terraform.tfvars.example. Use a strong password that meets Azure Windows VM complexity requirements."
  }
}

variable "avd_user_group_object_id" {
  description = "Microsoft Entra security group object ID whose members can use the AVD desktop."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.avd_user_group_object_id)) && var.avd_user_group_object_id != "00000000-0000-0000-0000-000000000000"
    error_message = "avd_user_group_object_id must be a valid GUID. Replace the zero-value placeholder from terraform.tfvars.example."
  }
}

variable "host_pool_type" {
  description = "AVD host pool type."
  type        = string
  default     = "Pooled"
  validation {
    condition     = var.host_pool_type == "Pooled"
    error_message = "This project supports only a pooled host pool."
  }
}

variable "load_balancer_type" {
  description = "AVD pooled host-pool load balancing method."
  type        = string
  default     = "BreadthFirst"
  validation {
    condition     = contains(["BreadthFirst", "DepthFirst"], var.load_balancer_type)
    error_message = "load_balancer_type must be BreadthFirst or DepthFirst for this pooled design."
  }
}

variable "maximum_sessions_allowed" {
  description = "Maximum concurrent sessions per pooled session host."
  type        = number
  default     = 10
  validation {
    condition     = var.maximum_sessions_allowed >= 1
    error_message = "maximum_sessions_allowed must be at least 1."
  }
}

variable "start_vm_on_connect" {
  description = "Enable AVD Start VM on Connect."
  type        = bool
  default     = true
}

variable "avd_service_principal_object_id" {
  description = "Object ID of the Azure Virtual Desktop service principal in this tenant. This is not its application ID."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.avd_service_principal_object_id)) && var.avd_service_principal_object_id != "00000000-0000-0000-0000-000000000000"
    error_message = "avd_service_principal_object_id must be the valid tenant-specific object ID of application 9cdead84-a844-4324-93f2-b2e6bb768d07."
  }
}

variable "autoscale_time_zone" {
  description = "Windows time-zone name used by the scaling plan."
  type        = string
  default     = "Central Standard Time"
}

variable "autoscale_schedules" {
  description = "Weekday and weekend schedules for one complete seven-day AVD lab cycle."
  type = list(object({
    name                                 = string
    days_of_week                         = list(string)
    ramp_up_start_time                   = string
    ramp_up_minimum_hosts_percent        = number
    ramp_up_capacity_threshold_percent   = number
    peak_start_time                      = string
    ramp_down_start_time                 = string
    ramp_down_minimum_hosts_percent      = number
    ramp_down_capacity_threshold_percent = number
    ramp_down_wait_time_minutes          = number
    ramp_down_force_logoff_users         = bool
    ramp_down_stop_hosts_when            = string
    off_peak_start_time                  = string
  }))

  default = [
    {
      name                                 = "weekdays"
      days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
      ramp_up_start_time                   = "07:00"
      ramp_up_minimum_hosts_percent        = 50
      ramp_up_capacity_threshold_percent   = 60
      peak_start_time                      = "09:00"
      ramp_down_start_time                 = "18:00"
      ramp_down_minimum_hosts_percent      = 0
      ramp_down_capacity_threshold_percent = 50
      ramp_down_wait_time_minutes          = 30
      ramp_down_force_logoff_users         = false
      ramp_down_stop_hosts_when            = "ZeroSessions"
      off_peak_start_time                  = "22:00"
    },
    {
      name                                 = "weekend"
      days_of_week                         = ["Saturday", "Sunday"]
      ramp_up_start_time                   = "09:00"
      ramp_up_minimum_hosts_percent        = 0
      ramp_up_capacity_threshold_percent   = 75
      peak_start_time                      = "10:00"
      ramp_down_start_time                 = "14:00"
      ramp_down_minimum_hosts_percent      = 0
      ramp_down_capacity_threshold_percent = 75
      ramp_down_wait_time_minutes          = 30
      ramp_down_force_logoff_users         = false
      ramp_down_stop_hosts_when            = "ZeroSessions"
      off_peak_start_time                  = "18:00"
    }
  ]

  validation {
    condition = (
      length(flatten([for schedule in var.autoscale_schedules : schedule.days_of_week])) == 7 &&
      length(toset(flatten([for schedule in var.autoscale_schedules : schedule.days_of_week]))) == 7 &&
      length(setsubtract(
        toset(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]),
        toset(flatten([for schedule in var.autoscale_schedules : schedule.days_of_week]))
      )) == 0 &&
      alltrue([for schedule in var.autoscale_schedules :
        schedule.ramp_up_minimum_hosts_percent >= 0 && schedule.ramp_up_minimum_hosts_percent <= 100 &&
        schedule.ramp_down_minimum_hosts_percent >= 0 && schedule.ramp_down_minimum_hosts_percent <= 100 &&
        schedule.ramp_up_capacity_threshold_percent >= 1 && schedule.ramp_up_capacity_threshold_percent <= 100 &&
        schedule.ramp_down_capacity_threshold_percent >= 1 && schedule.ramp_down_capacity_threshold_percent <= 100 &&
        contains(["ZeroSessions", "ZeroActiveSessions"], schedule.ramp_down_stop_hosts_when)
      ])
    )
    error_message = "autoscale_schedules must cover each day exactly once and use valid percentages and shutdown behavior."
  }
}

variable "autoscale_exclusion_tag" {
  description = "Tag name placed on a VM when it must be excluded from autoscale during maintenance."
  type        = string
  default     = "excludeFromScaling"
}

variable "storage_account_name" {
  description = "Globally unique lowercase Azure Storage Account name, 3-24 characters."
  type        = string
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "storage_replication_type" {
  description = "Azure Files storage replication."
  type        = string
  default     = "ZRS"
  validation {
    condition     = contains(["LRS", "ZRS"], var.storage_replication_type)
    error_message = "storage_replication_type must be LRS or ZRS."
  }
}

variable "fslogix_share_name" {
  description = "Azure Files share name for FSLogix profiles."
  type        = string
  default     = "profiles"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.fslogix_share_name)) && length(var.fslogix_share_name) >= 3 && length(var.fslogix_share_name) <= 63
    error_message = "fslogix_share_name must be 3-63 characters, lowercase, and use letters, numbers, or hyphens."
  }
}

variable "fslogix_share_quota_gb" {
  description = "Azure Files share quota in GiB."
  type        = number
  default     = 1024
  validation {
    condition     = var.fslogix_share_quota_gb >= 100
    error_message = "fslogix_share_quota_gb must be at least 100 GiB."
  }
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Workload  = "Azure Virtual Desktop"
  }
}

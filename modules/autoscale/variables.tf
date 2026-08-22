variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "host_pool_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "avd_service_principal_id" {
  type = string
}

variable "time_zone" {
  type = string
}

variable "schedules" {
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
}

variable "exclusion_tag" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "host_pool_name" { type = string }
variable "workspace_name" { type = string }
variable "application_group_name" { type = string }
variable "host_pool_type" { type = string }
variable "load_balancer_type" { type = string }
variable "maximum_sessions_allowed" { type = number }
variable "start_vm_on_connect" { type = bool }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "registration_base_time" { type = string }

variable "storage_account_name" {
  type = string
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account names must be 3-24 lowercase alphanumeric characters."
  }
}
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "replication_type" {
  type    = string
  default = "ZRS"
  validation {
    condition     = contains(["LRS", "ZRS"], var.replication_type)
    error_message = "replication_type must be LRS or ZRS."
  }
}
variable "fslogix_share_name" { type = string }
variable "fslogix_share_quota_gb" { type = number }
variable "tags" {
  type    = map(string)
  default = {}
}

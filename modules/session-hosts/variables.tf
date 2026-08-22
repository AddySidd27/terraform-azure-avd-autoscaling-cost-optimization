variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }
variable "session_host_count" { type = number }
variable "vm_name_prefix" { type = string }
variable "vm_size" { type = string }
variable "admin_username" { type = string }
variable "admin_password" {
  type      = string
  sensitive = true
}
variable "image_publisher" { type = string }
variable "image_offer" { type = string }
variable "image_sku" { type = string }
variable "image_version" { type = string }
variable "avd_registration_token" {
  type      = string
  sensitive = true
}
variable "fslogix_unc_path" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

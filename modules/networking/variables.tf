variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "address_space" { type = list(string) }
variable "session_host_subnet_name" { type = string }
variable "session_host_subnet_prefixes" { type = list(string) }
variable "tags" {
  type    = map(string)
  default = {}
}

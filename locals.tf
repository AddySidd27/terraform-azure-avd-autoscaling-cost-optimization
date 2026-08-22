locals {
  name_prefix = "${var.project_name}-${var.environment}"

  resource_group_name      = "rg-${local.name_prefix}"
  vnet_name                = "vnet-${local.name_prefix}"
  session_host_subnet_name = "snet-sessionhosts"
  nsg_name                 = "nsg-sessionhosts-${local.name_prefix}"
  host_pool_name           = "avd-hp-${local.name_prefix}"
  workspace_name           = "avd-ws-${local.name_prefix}"
  application_group_name   = "avd-dag-${local.name_prefix}"
  scaling_plan_name        = "avd-sp-${local.name_prefix}"
  session_host_name_prefix = "avdsh"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })
}

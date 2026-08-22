module "resource_group" {
  source = "./modules/resource-group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "networking" {
  source = "./modules/networking"

  name                         = local.vnet_name
  location                     = var.location
  resource_group_name          = module.resource_group.name
  address_space                = var.vnet_address_space
  session_host_subnet_name     = local.session_host_subnet_name
  session_host_subnet_prefixes = var.session_host_subnet_prefixes
  tags                         = local.common_tags
}

module "network_security_group" {
  source = "./modules/network-security-group"

  name                = local.nsg_name
  location            = var.location
  resource_group_name = module.resource_group.name
  subnet_id           = module.networking.session_host_subnet_id
  tags                = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  storage_account_name   = var.storage_account_name
  resource_group_name    = module.resource_group.name
  location               = var.location
  replication_type       = var.storage_replication_type
  fslogix_share_name     = var.fslogix_share_name
  fslogix_share_quota_gb = var.fslogix_share_quota_gb
  tags                   = local.common_tags
}

module "avd" {
  source = "./modules/avd"

  name_prefix              = local.name_prefix
  location                 = var.location
  resource_group_name      = module.resource_group.name
  host_pool_name           = local.host_pool_name
  workspace_name           = local.workspace_name
  application_group_name   = local.application_group_name
  host_pool_type           = var.host_pool_type
  load_balancer_type       = var.load_balancer_type
  maximum_sessions_allowed = var.maximum_sessions_allowed
  start_vm_on_connect      = var.start_vm_on_connect
  registration_base_time   = time_rotating.avd_registration.rfc3339
  tags                     = local.common_tags
}

module "autoscale" {
  source = "./modules/autoscale"

  name                     = local.scaling_plan_name
  location                 = var.location
  resource_group_name      = module.resource_group.name
  host_pool_id             = module.avd.host_pool_id
  subscription_id          = var.subscription_id
  avd_service_principal_id = var.avd_service_principal_object_id
  time_zone                = var.autoscale_time_zone
  schedules                = var.autoscale_schedules
  exclusion_tag            = var.autoscale_exclusion_tag
  tags                     = local.common_tags

  depends_on = [module.session_hosts]
}

module "session_hosts" {
  source = "./modules/session-hosts"

  resource_group_name    = module.resource_group.name
  location               = var.location
  subnet_id              = module.networking.session_host_subnet_id
  session_host_count     = var.session_host_count
  vm_name_prefix         = local.session_host_name_prefix
  vm_size                = var.session_host_vm_size
  admin_username         = var.admin_username
  admin_password         = var.admin_password
  image_publisher        = var.windows_image_publisher
  image_offer            = var.windows_image_offer
  image_sku              = var.windows_image_sku
  image_version          = var.windows_image_version
  avd_registration_token = module.avd.registration_token
  fslogix_unc_path       = module.storage.fslogix_unc_path
  tags                   = local.common_tags

  depends_on = [module.network_security_group]
}

module "rbac" {
  source = "./modules/rbac"

  application_group_id      = module.avd.application_group_id
  avd_user_group_object_id  = var.avd_user_group_object_id
  session_host_resource_ids = module.session_hosts.session_host_resource_ids
  file_share_id             = module.storage.file_share_id
}

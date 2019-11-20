module "core-infra" {
  source = "../../modules/core-infra"
  tags   = local.tags

  env                 = var.env
  resource_group_name = "core-infra-${var.env}-rg"
  vnet_name           = "core-infra-${var.env}-vnet"

  address_space                     = var.core_infra_vnet_address_space
  palo_mgmt_address_prefix          = var.palo_mgmt_address_prefix
  palo_trusted_address_prefix       = var.palo_trusted_address_prefix
  palo_untrusted_address_prefix     = var.palo_untrusted_address_prefix
  api_mgmt_address_prefix           = var.api_mgmt_address_prefix
  appgw_address_prefix              = var.appgw_address_prefix
  log_analytics_resource_group_name = "oms-automation-rg"
  bastion_address_prefix            = var.bastion_address_prefix
}


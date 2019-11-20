locals {
  trusted_vnet_name           = var.vnet_name
  trusted_vnet_resource_group = var.vnet_resource_group_name
  trusted_vnet_subnet_name    = "palo-trusted"
}

module "palo_alto" {
  source       = "github.com/hmcts/cnp-module-palo-alto.git?ref=master"
  subscription = var.subscription
  env          = var.env
  product      = var.product
  common_tags  = var.tags

  untrusted_vnet_name           = var.vnet_name
  untrusted_vnet_resource_group = var.vnet_resource_group_name
  untrusted_vnet_subnet_name    = "palo-untrusted"
  trusted_vnet_name             = var.vnet_name
  trusted_vnet_resource_group   = var.vnet_resource_group_name
  trusted_vnet_subnet_name      = local.trusted_vnet_subnet_name
  trusted_destination_host      = "${azurerm_storage_account.storage_account.name}.blob.core.windows.net"

  infra_vault_name           = var.core_infra_vault_name
  infra_vault_resource_group = var.core_infra_vault_resource_group_name
}

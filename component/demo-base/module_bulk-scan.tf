module "bulk-scan" {
  source = "../../modules/bulk-scan"

  providers = {
    azurerm        = "azurerm"
    azurerm.legacy = "azurerm.dcd-cnp-dev"
  }

  subscription             = var.subscription
  env                      = var.env
  external_cert_name       = var.wildcard_cert_name
  external_hostname        = var.bulk_scan_external_hostname
  resource_group_name      = var.bulk_scan_resource_group_name
  tags                     = local.tags
  vnet_name                = module.core-infra.vnet_name
  vnet_resource_group_name = module.core-infra.vnet_rg

  log_analytics_resource_group_name = module.core-infra.log_analytics_resource_group_name

  core_infra_vault_name                = "cftappsdata-demo"
  core_infra_vault_resource_group_name = "core-infra-demodata-rg"
  external_cert_resource_group_name    = "cnp-core-infra"
  external_cert_vault                  = "infra-vault-nonprod"
}

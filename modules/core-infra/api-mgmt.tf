module "api-mgmt" {
  source        = "git@github.com:hmcts/cnp-module-api-mgmt?ref=master"
  location      = var.location
  env           = var.env
  vnet_rg_name  = var.resource_group_name
  api_subnet_id = azurerm_subnet.api-mgmt.id
}
module "api-mgmt" {
  source        = "github.com/hmcts/cnp-module-api-mgmt?ref=u878-api_mgmt_tf"
  location      = var.location
  env           = var.env
  vnet_rg_name  = var.resource_group_name
  vnet_name     = var.vnet_name
  source_range  = var.address_space
  api_subnet_id = azurerm_subnet.api-mgmt.id
}

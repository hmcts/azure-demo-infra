resource "azurerm_log_analytics_workspace" "oms-automation" {
  name                = "hmcts-demodata-law"
  location            = var.location
  resource_group_name = var.log_analytics_resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

output "log_analytics_resource_group_name" {
  value = azurerm_log_analytics_workspace.oms-automation.resource_group_name
}
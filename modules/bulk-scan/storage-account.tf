locals {
  account_name = replace("${var.product}${var.env}", "-", "")

  // for each client service two containers are created: one named after the service
  // and another one, named {service_name}-rejected, for storing envelopes rejected by bulk-scan
  client_service_names = ["bulkscan", "sscs", "divorce", "probate", "finrem", "cmc"]
}

data "azurerm_subnet" "trusted_subnet" {
  name                 = local.trusted_vnet_subnet_name
  virtual_network_name = local.trusted_vnet_name
  resource_group_name  = local.trusted_vnet_resource_group
}

resource "azurerm_storage_account" "storage_account" {
  name                = local.account_name
  resource_group_name = var.resource_group_name

  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"

  custom_domain {
    name          = "${var.external_hostname}"
    use_subdomain = "false"
  }

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["213.121.161.124", "86.19.217.54"]
    virtual_network_subnet_ids = [data.azurerm_subnet.trusted_subnet.id]
    bypass                     = ["Logging", "Metrics", "AzureServices"]
  }

  tags = var.tags
}

resource "azurerm_storage_container" "service_containers" {
  name                 = local.client_service_names[count.index]
  storage_account_name = azurerm_storage_account.storage_account.name
  count                = length(local.client_service_names)
}

resource "azurerm_storage_container" "service_rejected_containers" {
  name                 = "${local.client_service_names[count.index]}-rejected"
  storage_account_name = azurerm_storage_account.storage_account.name
  count                = length(local.client_service_names)
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "storage_account_primary_key" {
  sensitive = true
  value     = azurerm_storage_account.storage_account.primary_access_key
}

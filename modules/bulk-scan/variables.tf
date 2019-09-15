variable "product" {
  default = "bulk-scanning" # bulk-scan already exists in demo, temporarily using bulk-scanning instead
}

variable "tags" {
  type = "map"
}

variable "external_hostname" {}
variable "external_cert_name" {}
variable "external_cert_vault" {}
variable "external_cert_resource_group_name" {}

variable "location" {
  default = "UK South"
}

variable "resource_group_name" {}
variable "log_analytics_resource_group_name" {}

variable "env" {}

variable "vnet_name" {}

variable "vnet_resource_group_name" {}
variable "core_infra_vault_resource_group_name" {}
variable "core_infra_vault_name" {}

variable "subscription" {}


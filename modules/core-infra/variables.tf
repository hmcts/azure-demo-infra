variable "location" {
  default = "UK South"
}

variable "resource_group_name" {}
variable "log_analytics_resource_group_name" {}

variable "vnet_name" {}
variable "address_space" {}
variable "palo_mgmt_address_prefix" {}
variable "palo_trusted_address_prefix" {}
variable "palo_untrusted_address_prefix" {}
variable "api_mgmt_address_prefix" {}
variable "appgw_address_prefix" {}
variable "bastion_address_prefix" {}

variable "env" {}
variable "tags" {
  type = "map"
}
